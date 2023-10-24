<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOC TYPE html>
<html lang="ko" xmlns:c="http://java.sun.com/jsp/jstl/core" xmlns:fmt="http://java.sun.com/jsp/jstl/fmt">
<head>
    <title>QnA List</title>
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no"/>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://kit.fontawesome.com/f3def94eb2.js" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="/css/common/base.css" type="text/css">
    <link rel="stylesheet" href="/css/qna/list.css" type="text/css">
</head>
<body>
<!-- ***** Nav start ***** -->
<%@ include file="../layout/layoutNav.jsp" %>
<div id="top" data-wow-duration="1s" data-wow-delay="0.5s">
    <div class="header-text" data-wow-duration="1s" data-wow-delay="1s">
    </div>
</div>
<!-- ***** Nav End ***** -->
<c:if test="${sessionScope.role == 3}">
    <%@ include file="../layout/layoutAdminSidebar.jsp" %>
</c:if>
<article class="question">
    <div class="btnWrap">
            <span>
                <button type="button" class="subBtn_q" onclick="location.href = contextpath + '/qna/write';">
                    문의등록
                </button>
            </span>
        <br/>
        <br/>
    </div>
    <section class="contents">
        <h4>문의 내역</h4>
        <div class="inner">
            <h5 class="sans">1:1 문의 내역이 <span class="blue">${questionPage.pagination.totalRecordCount}</span>건 있습니다.
            </h5>
            <div class="acco">
                <c:forEach var="question" items="${questionPage.list}">
                    <c:choose>
                        <c:when test="${empty question.answerDTO}">
                            <section class="three openacco">
                                <div class="q">
                                    <span class="yet">답변대기</span>
                                </div>
                            </section>
                        </c:when>
                        <c:otherwise>
                            <section class="three closeacco">
                                <div class="q">
                                    <span class="finish">답변완료</span>
                                </div>
                            </section>
                        </c:otherwise>
                    </c:choose>
                    <c:choose>
                        <c:when test="${fn:length(question.q_content) > 30}">
                            <p class="fontTitle"><c:out value="${fn:substring(question.q_content,0,29)}"/>...</p>
                        </c:when>
                        <c:otherwise>
                            <p class="fontTitle"><c:out value="${question.q_content}"/></p>
                        </c:otherwise>
                    </c:choose>
                    <p>▶</p>
                </c:forEach>
            </div>
            <div class="a">
                <div class="line">
                    <p class="fontSty">
                    <div class="category_content">
                        <c:choose>
                            <c:when test="${question.company_no==0}">
                                <span>[ 홈페이지 문의 - </span>
                            </c:when>
                            <c:otherwise>
                                <span>[ 공고 문의 - </span>
                            </c:otherwise>
                        </c:choose>
                        <span>${question.q_category} ]</span></div>
                    </p>
                    <p class="fontSty">
                        ${question.q_content}
                    </p>
                    <c:if test="${not empty question.questionFileDTOList}">
                   <span> 첨부파일 :
                     <c:forEach var="questionFile" items="${question.questionFileDTOList}">
                        <a class="no-hover" href="/qna/qfileDownload/${questionFile.QFile_no}"><div
                                class="file">${questionFile.QFile_orgName}</div></a>
                     </c:forEach>
                   </span>
                    </c:if>
                    <c:if test="${question.member_no eq sessionScope.memberNo  && sessionScope.role eq 1}">
                        <div class="btnWrap">
                            <span><button type="button" class="subBtn_q"
                                          onclick="modifyQuestion(${question.q_no});">수정</button></span>
                            <span><button type="button" class="subBtn_q"
                                          onclick="deleteQuestion(${question.q_no});">삭제</button></span>
                        </div>
                    </c:if>
                    <c:if test="${sessionScope.role eq 3}">
                        <div class="btnWrap">
                            <span><button type="button" class="subBtn_q"
                                          onclick="deleteQuestion(${question.q_no});">삭제</button></span>
                        </div>
                    </c:if>
                </div>
                <div class="answerDiv" id="answerDiv-${question.q_no}">
                    <c:choose>
                        <c:when test="${empty question.answerDTO}">
                            <strong>답변대기</strong>
                            <p class="fontSty">
                                아직 질문에 답변이 달리지 않았습니다. 영업일 기준 3일 이내로 회신드립니다.
                                <c:if test="${question.company_no==0 && sessionScope.role eq 3}">
                                    <div class="btnWrap">
                                        <button type="button" class="subBtn_q" onclick="answerForm(${question.q_no})">
                                            답글달기
                                        </button>
                                    </div>
                                </c:if>
                                <c:if test="${question.company_no eq companyNo && sessionScope.role eq 2 }">
                                    <div class="btnWrap">
                                        <button type="button" class="subBtn_q" onclick="answerForm(${question.q_no})">
                                            답글달기
                                        </button>
                                    </div>
                                </c:if>
                            </p>
                        </c:when>
                        <c:otherwise>
                            <strong>답변완료</strong>
                            <p>${question.answerDTO.a_content}</p>
                            <c:if test="${not empty question.answerDTO.answerFileDTOList}">
                           <span> 첨부파일 :
                             <c:forEach var="answerFile" items="${question.answerDTO.answerFileDTOList}">
                                 <a class="no-hover" href="/qna/afileDownload/${answerFile.AFile_no}"><div
                                         class="file">${answerFile.AFile_orgName}</div></a>
                             </c:forEach>
                           </span>
                            </c:if>
                            <c:if test="${question.company_no eq 0 && sessionScope.role eq 3}">
                                <div class="btnWrap">
                                    <span><button type="button" class="subBtn_q"
                                                  onclick="modifyAnswer(${question.q_no}); answerForm(${question.q_no});">수정</button></span>
                                    <span><button type="button" class="subBtn_q"
                                                  onclick="deleteAnswer(${question.answerDTO.a_no});">삭제</button></span>
                                </div>
                            </c:if>
                            <c:if test="${question.company_no eq companyNo && sessionScope.role eq 2 }">
                                <div class="btnWrap">
                                    <span><button type="button" class="subBtn_q"
                                                  onclick="modifyAnswer(${question.q_no}); answerForm(${question.q_no});">수정</button></span>
                                    <span><button type="button" class="subBtn_q"
                                                  onclick="deleteAnswer(${question.answerDTO.a_no});">삭제</button></span>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </section>
    <!-- pagenation start -->
    <nav aria-label="Page navigation">
        <ul class="pagenation" style="margin:0 0">
            <c:set var="page" value="${questionPage.pagination}"/>
            <c:if test="${page.firstPage>5}">
                <li class="page-item"><a class="page-link" href="javascript:void(0);"
                                         onclick="movePage(${page.firstPage-5})">pre</a></li>
            </c:if>
            <c:forEach var="pNo" begin="${page.firstPage}" end="${page.lastPage}" step="1">
                <c:choose>
                    <c:when test="${pNo != criteria.currentPageNo}">
                        <li class="page-item"><span><a class="page-link" href="javascript:void(0);"
                                                       onclick="movePage(${pNo})">${pNo}</a></span></li>
                    </c:when>
                    <c:otherwise>
                        <li class="page-item"><span>${pNo}</span></li>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
            <c:if test="${page.lastPage<page.totalPageCount}">
                <li class="page-item"><a class="page-link" href="javascript:void(0);"
                                         onclick="movePage(${page.firstPage+5})">next</a></li>
            </c:if>
        </ul>
    </nav>
    <!-- pagenation end -->
    </section>
</article>
</body>
<!-- Footer start -->
<%@ include file="../layout/layoutFooter.jsp" %>
<!-- Footer end -->
<%@include file="../layout/layoutFooter.jsp" %>
<script src="/css/template/vendor/jquery/jquery.min.js"></script>
<script src="/css/template/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="/css/template/assets/js/owl-carousel.js"></script>
<script src="/css/template/assets/js/animation.js"></script>
<script src="/css/template/assets/js/imagesloaded.js"></script>
<script src="/css/template/assets/js/popup.js"></script>
<script src="/css/template/assets/js/custom.js"></script>
<script src="/css/template/assets/js/side.js"></script>

<script>
    var accItem = document.getElementsByClassName('three');
    var accHD = document.getElementsByClassName('q');
    for (i = 0; i < accHD.length; i++) {
        accHD[i].addEventListener('click', toggleItem, false);
    }

    function toggleItem() {
        var itemClass = this.parentNode.className;
        for (i = 0; i < accItem.length; i++) {
            accItem[i].className = 'three closeacco';
        }
        if (itemClass === 'three closeacco') {
            this.parentNode.className = 'three openacco';
        }
    }

    function movePage(currentPageNo) {
        const queryParams = {
            currentPageNo: (currentPageNo) ? currentPageNo : 1,
            recordsPerPage: 3,
            pageSize: 5,
        }
        const queryString = new URLSearchParams(queryParams).toString();
        const url = location.pathname + ((queryString !== "") ? "?" + queryString : "");
        location.href = url;
    }

    function answerForm(qNo) {
        let html = '';
        html += '<form action="/qna/answer" enctype ="multipart/form-data" method="post" name="writeFrom" id="writeFrom" class="txt">';
        html += '<input type="hidden" id="q_no" name="q_no" value="' + qNo + '">';
        html += '<textarea name="a_content" id="textarea" placeholder="문의내용을 입력하세요.(3000자 이내)" rows="10" cols="30"></textarea>';
        html += '<span class="length" id="length">(0/3000자)</span>';
        html += '<div class="fileUpload">';
        html += '<label for="aFile_orgName"><div class="upload">첨부파일</div></label>';
        html += '<input type="file" name="aFile_orgName" id="aFile_orgName" multiple="multiple" />';
        html += '<div id="att_zone"></div>';
        html += '</div>';
        html += '<h5 class="h-class">5MB이하의 파일(JPG, PNG, GIF, PDF) 최대 3개까지 첨부하실 수 있습니다.</h5>';
        html += '<button type="submit" name="subBtn">등록하기</button>';

        $("#answerDiv-" + qNo).empty().append(html);
        showUploadResult();
        $("#textarea").keyup(function (e) {
            var content = $(this).val();
            $("#length").html("(" + content.length + " / 3000)");
            if (content.length > 3000) {
                alert("최대 3000자까지 입력 가능합니다.");
                $(this).val(content.substring(0, 3000));
                $('#length').html("(3000 / 최대 3000자)");
            }
        });
    }

    showUploadResult = function showUploadResult() {
        var attZone = document.getElementById('att_zone');
        var aFile_orgName = document.getElementById('aFile_orgName');
        var str = "";
        var sel_files = [];

        // 속성
        var div_style = 'display:inline-flex;padding:6px 12px;border: 1px solid #171717; margin : 5px;'
            + 'border-radius:4px;align-items:center;font-weight:400;'
            + 'font-size: .8125rem; letter-spacing: -.005em; line-height: 20px; height: 34px';
        var btn_style = 'border:none';

        aFile_orgName.addEventListener('change', function (e) {
            var files = e.target.files;
            var fileArr = Array.prototype.slice.call(files);
            for (var f of fileArr) {
                fileListLoader(f);
            }
        });

        fileListLoader = function (file) {
            sel_files.push(file);
            attZone.appendChild(makeIcon(file));
        }

        makeIcon = function (file) {
            var div = document.createElement('div');
            div.setAttribute('style', div_style);

            var fileSpan = document.createElement('span');
            fileSpan.setAttribute('id', 'fileName');

            var fileSpanText = document.createTextNode(file.name);
            fileSpan.appendChild(fileSpanText);

            var btn = document.createElement('button');
            btn.setAttribute('type', 'button');
            btn.setAttribute('class', 'no-hover');
            btn.setAttribute('delFile', file.name);
            btn.setAttribute('style', btn_style);
            btn.onclick = function (ev) {
                var ele = ev.srcElement;
                var delFile = ele.getAttribute('delFile');
                for (var i = 0; i < sel_files.length; i++) {
                    if (delFile == sel_files[i].name) {
                        sel_files.splice(i, 1);
                    }
                }
                dt = new DataTransfer();
                for (f in sel_files) {
                    var file = sel_files[f];
                    dt.items.add(file);
                }
                aFile_orgName.files = dt.files;
                var p = ele.parentNode;
                attZone.removeChild(p);
            }

            var icon = document.createElement('i');
            icon.setAttribute('class', 'fa-solid fa-xmark fa-lg');
            icon.setAttribute('style', 'color: #5a5858; margin-left : 5px;');
            icon.setAttribute('id', 'icon-x');

            icon.onclick = function (event) {
                event.stopPropagation();
                btn.click();
            };

            btn.appendChild(icon);
            div.appendChild(fileSpan);
            div.appendChild(btn);
            return div;
        }
    };

    function modifyQuestion(qNo) {
        window.location.href = '/qna/modify/' + qNo;
    }

    function deleteQuestion(qNo) {
        window.location.href = '/qna/delete/' + qNo;
    }

    function modifyAnswer(qNo) {
        $.ajax({
            url: '/qna/modifyAnswer',
            type: 'GET',
            contentType: 'application/json',
            data: {qNo: qNo},
            success: function (data) {
                console.log(data);
                let html = '';
                html += '<form action="/qna/modifyAnswer" enctype ="multipart/form-data" method="post" name="writeFrom" id="writeFrom" class="txt">';
                html += '<input type="hidden" id="a_no" name="a_no" value="' + data.a_no + '">';
                html += '<textarea name="a_content" id="textarea" rows="10" cols="30">' + data.a_content + '</textarea>';
                html += '<span class="length" id="length">(0/3000자)</span>';
                html += '<div class="fileUpload">';
                html += '<label for="aFile_orgName"><div class="upload">첨부파일</div></label>';
                html += '<input type="file" name="aFile_orgName" id="aFile_orgName" multiple="multiple" />';
                html += '<div id="att_zone"></div>';
                html += '</div>';
                html += '<h5 class="h-class">5MB이하의 파일(JPG, PNG, GIF, PDF) 최대 3개까지 첨부하실 수 있습니다.</h5>';
                html += '<button type="submit" name="subBtn">등록하기</button>';

                $("#answerDiv-" + qNo).empty().append(html);

                var fileListArray = data.answerFileDTOList;
                var attZone = document.getElementById('att_zone');
                var aFile_orgName = document.getElementById('aFile_orgName');
                var str = "";
                var sel_files = [];

                var div_style = 'display:inline-flex;padding:6px 12px;border: 1px solid #171717; margin : 5px;'
                    + 'border-radius:4px;align-items:center;font-weight:400;'
                    + 'font-size: .8125rem; letter-spacing: -.005em; line-height: 20px; height: 34px';
                var btn_style = 'border:none';

                aFile_orgName.addEventListener('change', function (e) {
                    var files = e.target.files;
                    var fileArr = Array.prototype.slice.call(files);
                    for (var f of fileArr) {
                        fileListLoader(f);
                    }
                });

                fileListLoader = function (file) {
                    sel_files.push(file);
                    attZone.appendChild(makeIcon(file));
                }

                makeIcon = function (file) {
                    var div = document.createElement('div');
                    div.setAttribute('style', div_style);

                    var fileSpan = document.createElement('span');
                    fileSpan.setAttribute('id', 'fileName');

                    var fileSpanText = document.createTextNode(file.name);
                    fileSpan.appendChild(fileSpanText);

                    var btn = document.createElement('button');
                    btn.setAttribute('type', 'button');
                    btn.setAttribute('class', 'no-hover');
                    btn.setAttribute('delFile', file.name);
                    btn.setAttribute('style', btn_style);
                    btn.onclick = function (ev) {
                        var ele = ev.srcElement;
                        var delFile = ele.getAttribute('delFile');
                        for (var i = 0; i < sel_files.length; i++) {
                            if (delFile == sel_files[i].name) {
                                sel_files.splice(i, 1);
                            }
                        }
                        dt = new DataTransfer();
                        for (f in sel_files) {
                            var file = sel_files[f];
                            dt.items.add(file);
                        }
                        aFile_orgName.files = dt.files;
                        var p = ele.parentNode;
                        attZone.removeChild(p);
                    }

                    var icon = document.createElement('i');
                    icon.setAttribute('class', 'fa-solid fa-xmark fa-lg');
                    icon.setAttribute('style', 'color: #5a5858; margin-left : 5px;');
                    icon.setAttribute('id', 'icon-x');

                    icon.onclick = function (event) {
                        event.stopPropagation();
                        btn.click();
                    };

                    btn.appendChild(icon);
                    div.appendChild(fileSpan);
                    div.appendChild(btn);
                    return div;
                }

                /* 기존에 저장된 이미지 div 반환 */
                makePreDiv = function (data, hiddenInput) {
                    var div = document.createElement('div');
                    div.setAttribute('style', div_style);

                    var fileSpan = document.createElement('span');
                    fileSpan.setAttribute('id', 'fileName');

                    var fileSpanText = document.createTextNode(data.afile_orgName);
                    fileSpan.appendChild(fileSpanText);
                    var btn = document.createElement('button');
                    btn.setAttribute('type', 'button');
                    btn.setAttribute('class', 'no-hover');
                    btn.setAttribute('delFile', data.name);
                    btn.setAttribute('style', btn_style);
                    btn.onclick = function (ev) {
                        var ele = ev.srcElement;
                        var p = ele.parentNode;
                        attZone.removeChild(p);
                        var hiddenInput = ele.parentNode.querySelector('#hiddenField');
                        if (hiddenInput) {
                            hiddenInput.parentNode.removeChild(hiddenInput);
                        }
                        ;
                    };

                    var icon = document.createElement('i');
                    icon.setAttribute('class', 'fa-solid fa-xmark fa-lg');
                    icon.setAttribute('style', 'color: #5a5858; margin-left : 5px;');
                    icon.setAttribute('id', 'icon-x');
                    icon.onclick = function (event) {
                        event.stopPropagation();
                        btn.click();
                    };

                    btn.appendChild(icon);
                    div.appendChild(fileSpan);
                    div.appendChild(btn);
                    return div;
                };

                fileListArray.forEach(function (item) {
                    let hiddenInput = document.createElement('input');
                    hiddenInput.setAttribute('type', 'hidden');
                    hiddenInput.setAttribute('name', 'preFileNo');
                    hiddenInput.setAttribute('id', 'hiddenField');
                    hiddenInput.setAttribute('value', item.afile_no);
                    attZone.appendChild(makePreDiv(item, hiddenInput));
                });

                $("#textarea").keyup(function (e) {
                    var content = $(this).val();
                    $("#length").html("(" + content.length + " / 3000)");
                    if (content.length > 3000) {
                        alert("최대 3000자까지 입력 가능합니다.");
                        $(this).val(content.substring(0, 3000));
                        $('#length').html("(3000 / 최대 3000자)");
                    }
                });
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.error('Error:', errorThrown);
            }
        });
    }

    function deleteAnswer(aNo) {
        window.location.href = '/qna/deleteAnswer/' + aNo;
    }
</script>
</html>