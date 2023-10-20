<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="cPath" value="<%=request.getContextPath() %>"/>
<html>
<head>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <link rel="stylesheet" href="/css/resume/list.css" type="text/css"/>
    <title>JOB START UP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
<header>
    <%@ include file="../../layout/layoutNav.jsp" %>
    <div  id="top" data-wow-duration="1s" data-wow-delay="0.5s">
        <div class="header-text" data-wow-duration="1s" data-wow-delay="1s">
        </div>
    </div>
</header>
<%@ include file="../../layout/layoutSideSeeker.jsp" %>
<main>
    <div class="resume_wrap">
        <h3 class="resume_title">면접일정 조회</h3>
        <c:forEach var="result" items="${statusResult}">
            <c:forEach var="resume" items="${result.resumeDTOList}">
                <c:if test="${result.interview_date != null}">
                <li class="resume_item">
                        <span><a href="${cPath}/seeker/resumeDetail/${result.posting_no}">공고제목</a>
                        <div><a href="${cPath}/seeker/resumeDetail/${result.resume_no}">이력서 보러가기 ${resume.resume_title}</a></div>
                        </span>
                        <span>
                            <button class="modifyBtn" type="button">
                                <fmt:formatDate value="${result.interview_date}" pattern="yyyy/MM/dd" var="formattedDate" />
                                ${formattedDate}
                            </button>
                        </span>
                </li>
                </c:if>
            </c:forEach>
        </c:forEach>
    </div>

</main>
    <%@ include file="../../layout/layoutFooter.jsp" %>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="/css/template/assets/js/side.js"></script>
</body>
</html>
