package com.pickmeup.jobstartup.member.service;

import com.pickmeup.jobstartup.member.dto.JoinCommonDTO;
import com.pickmeup.jobstartup.member.dto.JoinCompanyDTO;
import com.pickmeup.jobstartup.member.entity.Member;
import com.pickmeup.jobstartup.member.entity.MemberType;
import com.pickmeup.jobstartup.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.nurigo.sdk.message.model.Message;
import net.nurigo.sdk.message.request.SingleMessageSendingRequest;
import net.nurigo.sdk.message.response.SingleMessageSentResponse;
import net.nurigo.sdk.message.service.DefaultMessageService;
import org.modelmapper.ModelMapper;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class MemberServiceImpl implements MemberService {
    private final MemberRepository memberRepository;
    private final ModelMapper modelMapper;
    private final BCryptPasswordEncoder passwordEncoder;
    private final DefaultMessageService messageService;
    private final UserSecurityService userSecurityService;
    private final AuthenticationManager authenticationManager;

    //아이디 중복 여부 검사
    @Override
    public boolean isDuplicateMemberId(String memberId) {
        int count = memberRepository.countByMemberId(memberId);
        return count > 0;
    }

    //일반회원가입
    @Override
    public Member join(JoinCommonDTO joinCommonDTO) {
        if (!isValidDate(joinCommonDTO.getMember_birth())) {
            throw new IllegalArgumentException("YYYYMMDD 입력 형식을 확인해 주세요");
        }

        if (joinCommonDTO.getMember_id().contains("admin")) {
            joinCommonDTO.setMember_type(MemberType.ADMIN);
        }

        log.info("Before conversion: {}", joinCommonDTO.toString());
        Member member = convertDtoToEntity(joinCommonDTO);
        log.info("After conversion: {}", member.toString());

        String encryptedPassword = passwordEncoder.encode(joinCommonDTO.getMember_pw());
        member.setMember_pw(encryptedPassword);


        memberRepository.savePerson(member);
        log.info("서비스 Loaded user: {}, with authorities: {}", member.getMember_id(), member.getMember_type());
        return member;
    }

    //기업 회원가입
    @Override
    public Member join(JoinCompanyDTO joinCompanyDTO) {
        if (!isValidDate(joinCompanyDTO.getMember_birth())) {
            throw new IllegalArgumentException("YYYYMMDD 입력 형식을 확인해 주세요");
        }

        Member member = convertDtoToEntity(joinCompanyDTO);

        String encryptedPassword = passwordEncoder.encode(joinCompanyDTO.getMember_pw());
        member.setMember_pw(encryptedPassword);


        member.setBusiness_no(joinCompanyDTO.getBusiness_no());

        memberRepository.saveCompany(member);
        log.info("서비스 Loaded user: {}, with authorities: {}", member.getMember_id(), member.getMember_type());
        return member;
    }

    //회원 구분에 따른 메뉴ID 가져오기
    @Override
    public String getMemberMenuId(String memberType) {
        return memberRepository.selectMenuId(memberType);
    }

    private <T> Member convertDtoToEntity(T dto) {
        Member member = modelMapper.map(dto, Member.class);
        return member;
    }

    //생년월일 유효성 검사
    public boolean isValidDate(String birthDate) {
        if (birthDate.length() != 8) {
            return false;
        }

        try {
            Integer.parseInt(birthDate);
        } catch (NumberFormatException e) {
            return false;
        }

        int year = Integer.parseInt(birthDate.substring(0, 4));
        int month = Integer.parseInt(birthDate.substring(4, 6));
        int day = Integer.parseInt(birthDate.substring(6, 8));

        if (month < 1 || month > 12 || day < 1 || day > 31) {
            return false;
        }

        if ((month == 4 || month == 6 || month == 9 || month == 11) && day == 31) {
            return false;
        }

        if (month == 2) {
            if (day > 29) {
                return false;
            }
            if (day == 29) {
                if (!(year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))) {
                    return false;
                }
            }
        }

        return true;
    }

    //4자리 인증번호 받기
    @Override
    public boolean sendSMS(String userPhoneNumber, String randomNumber) {
        Message message = new Message();
        message.setFrom("01099133180");
        message.setTo(userPhoneNumber);
        message.setText("인증번호는 " + randomNumber + "입니다.");

        try {
            SingleMessageSentResponse response = messageService.sendOne(new SingleMessageSendingRequest(message));

            if("2000".equals(response.getStatusCode())) {
                return true;
            } else {
                return false;
            }
        } catch(Exception e) {
            return false;
        }
    }

    @Override
    public boolean isDuplicateEmail(String emailInput) {
        return memberRepository.countByEmail(emailInput) > 0;
    }

    //회원 객체를 자동으로 로그인한 상태로 만듦
    @Override
    public void autoLogin(Member member) {
        UserDetails userDetails = userSecurityService.loadUserByUsername(member.getMember_id());
        //UsernamePasswordAuthenticationToken는 인증 객체. UserDetails(사용자 정보)와 사용자의 권한을 기반으로 토큰 생성.
        UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
        //생성한 토큰을 현재 SecurityContext에 설정. 해당 사용자를 로그인한 상태로 만듦.
        SecurityContextHolder.getContext().setAuthentication(authenticationToken);
    }

    //사업자등록번호 중복 확인
    @Override
    public boolean isDuplicateBusinessNo(String business_no) {
        return memberRepository.findByBusinessNo(business_no) != null;
    }

    //개인회원 아이디 찾기
    public String findPersonId(String name, String phone) {
        String foundId = memberRepository.findPersonId(name, phone);
        return foundId;
    }

    //개인회원 비밀번호 찾기
    @Override
    public Member findPersonPassword(String memberId, String memberName, String memberPhone) {
        return memberRepository.findPersonPassword(memberId, memberName, memberPhone);
    }

    //개인회원 비밀번호 재설정
    @Override
    public void updatePassword(String memberId, String newPassword) {
        log.info("서비스 진입: {}", memberId);
        String encryptedPassword = passwordEncoder.encode(newPassword);
        log.info("Password encrypted");

        try {
            memberRepository.updatePassword(memberId, encryptedPassword);
        } catch (Exception e) {
            log.error("memberRepository.updatePassword: {}", memberId, e);
        }
        log.info("서비스 끝");
    }

    //기업회원 아이디 찾기
    @Override
    public String findCompanyId(String name, String business_no) {
        return memberRepository.findCompanyId(name, business_no);
    }

    //기업회원 비밀번호 찾기
    @Override
    public Member findCompanyPassword(String memberId, String memberName, String memberPhone) {
        return memberRepository.findCompanyPassword(memberId, memberName, memberPhone);
    }

    //기업회원 비밀번호 재설정
    @Override
    public void updateCompanyPassword(String memberId, String newPassword) {
        String encryptedPassword = passwordEncoder.encode(newPassword);

        try {
            memberRepository.updateCompanyPassword(memberId, encryptedPassword);
        } catch (Exception e) {
            log.error("memberRepository.updatePassword: {}", memberId, e);
        }
    }

    //회원 번호로 멤버 객체 가져오기
    @Override
    public Member getMember(String memberId) {
        Member member = memberRepository.selectMemberById(memberId);
        return member;
    }

    //회원 번호로 멤버 객체 가져오기
    @Override
    public Member getMemberNo(long memberNo) {
        Member member = memberRepository.selectMemberByNo(memberNo);
        return member;
    }

    //탈퇴하기
    @Override
    public void withdrawal(Long member_no) {
        memberRepository.withdrawal(member_no);
        SecurityContextHolder.getContext().setAuthentication(null);
        log.info("사용자 탈퇴 처리 완료: {}", member_no);
    }

    //username으로 member_no 찾기
    @Override
    public Long findMemberNoByUsername(String username) {
        return memberRepository.findMemberNoByUsername(username);
    }
}