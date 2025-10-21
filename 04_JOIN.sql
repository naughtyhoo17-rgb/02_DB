/*
[JOIN 용어 정리]
  
  오라클                              SQL : 1999표준(ANSI)
-----------------------------------------------------------------------------
 등가 조인                      내부 조인(INNER JOIN), JOIN USING / ON
                          + 자연 조인(NATURAL JOIN, 등가 조인 방법 중 하나)
-----------------------------------------------------------------------------
 포괄 조인                     왼쪽 외부 조인(LEFT OUTER), 오른쪽 외부 조인(RIGHT OUTER)
                          + 전체 외부 조인(FULL OUTER, 오라클 구문으로는 사용 못함)
-----------------------------------------------------------------------------
자체 조인, 비등가 조인                        JOIN ON
-----------------------------------------------------------------------------
카테시안(카티션) 곱                   교차 조인(CROSS JOIN)
CARTESIAN PRODUCT


- 미국 국립 표준 협회(American National Standards Institute, ANSI)
 미국의 산업 표준을 제정하는 민간단체.
- 국제표준화기구 ISO에 가입되어 있음.
*/

-----------------------------------------------------------------------------

-- JOIN
-- 하나 이상의 테이블에서 데이터를 조회하기 위해 사용.
-- 수행 결과는 하나의 Result Set으로 나옴.


-- (참고) JOIN은 서로 다른 테이블의 행을 하나씩 이어 붙이기 때문에
--       시간이 오래 걸리는 단점이 있다!


/*
- 관계형 데이터베이스에서 SQL을 이용해 테이블간 '관계'를 맺는 방법.


- 관계형 데이터베이스는 최소한의 데이터를 테이블에 담고 있어
  원하는 정보를 테이블에서 조회하려면 한 개 이상의 테이블에서
  데이터를 읽어와야 되는 경우가 많다.
  이 때, 테이블간 관계를 맺기 위한 연결고리 역할이 필요한데,
  두 테이블에서 같은 데이터를 저장하는 컬럼이 연결고리가됨.  
*/

-----------------------------------------------------------------------------

-- 사번, 이름, 부서 코드, 부서명 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM EMPLOYEE;

-- 부서명은 DEPARTMENT 테이블에서 조회 가능한 컬럼
SELECT DEPT_TITLE FROM DEPARTMENT;

SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE
JOIN DEPARTMENT ON(DEPT_CODE = DEPT_ID);
-- *테이블 간의 관계를 잘 파악하여 JOIN이 가능한지 알아야 함!*

-- 1. 내부 조인 (INNER JOIN, 등가조인, EQUAL JOIN)
-- => 연결되는 컬럼의 값이 일치하는 행들만 조인 가능.
-- => 일치하는 값이 없는 행(ex) null..)은 조인에서 제외됨.

-- 작성 방법은 크게 ANSI 구문과 오라클 구문으로 나뉘고
-- ANSI 내에서 USING과 ON을 쓰는 방법으로 나뉜다.

-- 1) 연결에 사용할 두 컬럼명이 다른 경우
-- ANSI 구문
-- 연결에 사용할 컬럼명이 다른 경우 => ON() 사용
SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE
JOIN DEPARTMENT ON(DEPT_CODE = DEPT_ID); -- 위의 예시

-- 오라클 구문
SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE = DEPT_ID;

-- DEPARTMENT 테이블, LOCATION 테이블을 참조하여
-- 부서명, 지역명 조회
SELECT * FROM DEPARTMENT; -- LOCATION_ID
SELECT * FROM LOCATION; -- LOCAL_CODE

 -- ANSI 방식
SELECT DEPT_TITLE, LOCAL_NAME
FROM DEPARTMENT
JOIN LOCATION ON (LOCATION_ID = LOCAL_CODE);

-- 오라클 방식
SELECT DEPT_TITLE, LOCAL_NAME
FROM DEPARTMENT, LOCATION
WHERE LOCATION_ID = LOCAL_CODE;

-- 2) 연결에 사용할 두 컬럼명이 같은 경우

-- EMPLOYEE, JOB 테이블 참조하여
-- 사번, 이름, 직급 코드, 직급명 조회

SELECT * FROM EMPLOYEE; -- JOB_CODE
SELECT * FROM JOB; -- JOB_CODE

-- ANSI 구문
-- 연결에 사용할 컬럼명이 같은 경우 USING(컬럼명) 사용
SELECT EMP_ID, EMP_NAME, JOB_CODE, JOB_NAME
FROM EMPLOYEE
JOIN JOB USING (JOB_CODE);

-- 오라클 구문
SELECT EMP_ID, EMP_NAME, JOB_CODE, JOB_NAME
FROM EMPLOYEE, JOB
WHERE JOB_CODE = JOB_CODE;
-- ORA-00918: 열의 정의가 애매합니다 (=> JOB_CODE 누구껀지 모르겠다)

SELECT EMP_ID, EMP_NAME, E.JOB_CODE, JOB_NAME -- E나 J 무관
FROM EMPLOYEE E, JOB J
WHERE E.JOB_CODE = J.JOB_CODE;
-- 별칭을 붙여 구분하여 확실하게 해준다

----------------------------------------------------------------

-- 2. 외부 조인 (OUTER JOIN)

-- 두 테이블의 지정하는 컬럼값이 일치하지 않는 행도 조인에 포함 시킴
-- * 반드시 OUTER JOIN 명시해야!(INNER는 안써도 ok)
SELECT EMP_ID, EMP_NAME, DEPT_CODE, DEPT_TITLE
FROM EMPLOYEE
/*INNER*/ JOIN DEPARTMENT ON(DEPT_CODE = DEPT_ID);

-- 1) LEFT [OUTER] JOIN
-- 	: 합치기에 사용한 두 테이블 중 왼편에 기술된 테이블의 컬럼 수를 기준으로 JOIN
-- => 왼편에 작성된 테이블의 모든 행이 결과에 포함되어야 한다.
-- (= JOIN이 안되는 행도 결과에는 포함)

-- ANSI 표준
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE LEFT OUTER JOIN DEPARTMENT
-- 왼편에 기술된 EMPLOYEE 기준으로 JOIN
ON(DEPT_CODE = DEPT_ID); -- 23행 (DEPT_CODE가 NULL인 2인도 포함)

SELECT EMP_NAME, DEPT_TITLE
FROM DEPARTMENT LEFT OUTER JOIN EMPLOYEE
-- 왼편에 기술된 DEPARTMENT 기준으로 JOIN
ON(DEPT_ID = DEPT_CODE); -- 24행 (DEPARTMENT 기준이므로 사람이 없는 부서도 표시)

-- 오라클 구문
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE = DEPT_ID(+);
-- 기준의 반대쪽 테이블의 컬럼에 (+) 기호 붙여서 작성! 

-- 2) RIGHT [OUTER] JOIN
-- : 합치기에 사용한 두 테이블 중 오른편에 기술된 테이블의 컬럼 수를 기준으로 JOIN

-- ANSI 표준
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE RIGHT OUTER JOIN DEPARTMENT/*기준*/
ON (DEPT_CODE = DEPT_ID); -- 24행(기준에 따라 사람없는 부서까지도 출력)

-- 오라클 구문
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE(+) = DEPT_ID;
-- DEPARTMENT가 기준이므로 EMPLOYEE의 컬럼인 DEPT_CODE에 (+)

-- 3) FULL [OUTER] JOIN
-- : 합치기에 사용한 두 테이블이 가진 모든 행을 결과에 포함
-- ** 오라클 구문 FULL OUTER JOIN 사용 불가 (없음)**

-- ANSI 표준
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE FULL JOIN DEPARTMENT
ON (DEPT_CODE = DEPT_ID); --26행
		--(내부조인과 비교해 EMP에 NULL 2개, DEPT에 NULL 3개까지 모두 포함)

-- 오라클 구문
SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE, DEPARTMENT
WHERE DEPT_CODE(+) = DEPT_ID(+);
-- ORA-01468: outer-join된 테이블은 1개만 지정할 수 있습니다
-- => 오라클은 FULL JOIN 불가!

-----------------------------------------------------------------

-- 3. 교차 조인 (CROSS JOIN, CARTESIAN PRODUCT)
-- 조인되는 테이블의 각 행들이 모두 MAPPING된 데이터가 검색되는 방법(곱집합)
-- => 의도와 달리 JOIN구문을 잘못 작성하는 경우 CROSS JOIN의 결과가 조회됨

SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE
CROSS JOIN DEPARTMENT;

------------------------------------------------------------------

-- 4. 비등가 조인 (NON EQUAL JOIN)
-- '=' (등호)를 사용하지 않는 JOIN문
-- 지정한 컬럼값이 일치하는 경우가 아닌, 값의 범위에 포함되는 행들을 연결하는 방식

SELECT * FROM SAL_GRADE;

SELECT EMP_NAME, SAL_LEVEL FROM EMPLOYEE;

-- 사원의 급여에 따라 급여 등급 파악하기
SELECT EMP_NAME, SALARY, SAL_GRADE.SAL_LEVEL
FROM EMPLOYEE
JOIN SAL_GRADE ON(SALARY BETWEEN MIN_SAL AND MAX_SAL);

-----------------------------------------------------------------

-- 5. 자체 조인 (SELF JOIN)

-- 같은 테이블의 조인 => 자기 자신과 조인
-- * TIP! 같은 테이블 2개 있다고 생각하고 JOIN 작성
-- 테이블마다 별칭 작성 bcuz 같은 테이블이므로 모든 컬럼명이 같아 열의 정의 애매함 방지

-- 사번, 이름, 사수의 사번, 사수 이름 조회
-- 단, 사수가 없으면 '없음', '-' 조회

SELECT * FROM EMPLOYEE;
SELECT * FROM EMPLOYEE;

-- ANSI 표준
SELECT E1.EMP_ID 사번, E1.EMP_NAME "사원 이름",
NVL(E1.MANAGER_ID, '없음') "사수의 사번",
NVL(E2.EMP_NAME, '-') "사수 이름"
FROM EMPLOYEE E1 LEFT JOIN EMPLOYEE E2
ON (E1.MANAGER_ID = E2.EMP_ID);

-- 오라클 구문
SELECT E1.EMP_ID 사번, E1.EMP_NAME "사원 이름",
NVL(E1.MANAGER_ID, '없음') "사수의 사번",
NVL(E2.EMP_NAME, '-') "사수 이름"
FROM EMPLOYEE E1, EMPLOYEE E2
WHERE E1.MANAGER_ID = E2.EMP_ID(+); 

----------------------------------------------------------------

-- 6. 자연 조인 (NATURAL JOIN)
-- 동일한 타입과 이름을 가진 컬럼이 있는 테이블 간의 조인을 간단히 표현하는 방법
-- 반드시 두 테이블 간에 동일한 컬럼명, 타입을 가진 컬럼이 있어야 한다

SELECT JOB_CODE FROM EMPLOYEE;
SELECT JOB_CODE FROM JOB;

SELECT EMP_NAME, JOB_NAME
FROM EMPLOYEE
-- JOIN JOB USING(JOB_CODE); 대신에
NATURAL JOIN JOB; -- 컬럼명 안써도 ok

SELECT EMP_NAME, DEPT_TITLE
FROM EMPLOYEE
NATURAL JOIN DEPARTMENT;
-- 잘못 조인하면 CROSS JOIN 결과가 나옴
-- => 테이블 간 컬럼명이 달라 자연 조인이 아닌 교차 조인이 된 것

-- cf) 자연 조인을 다중 조인에서 사용 시
-- 	SELECT절에 자연 조인에서 사용되었을 연결고리 컬럼을 반드시 작성해야!

-----------------------------------------------------------------

-- 7. 다중 조인
-- n개의 테이블을 조인할 때 사용 (순서 중요!!!)

-- 사원 이름, 부서명, 지역명 조회
-- EMP_NAME (EMPLOYEE)
-- DEPT_TITLE (DEPARTMENT)
-- LOCAL_NAME (LOCATION)
-- => 총 3개의 테이블 필요 / EMPLOYEE와 LOCATION 직접 조인 불가!
-- thus (EMPLOYEE + DEPARTMENT) 조인한 result set을 다시 LOCATION과 조인

-- ANSI 표준
SELECT EMP_NAME, DEPT_TITLE, LOCAL_NAME
FROM EMPLOYEE
JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID) -- EMP와 DEPT 먼저 조인
JOIN LOCATION ON(LOCATION_ID = LOCAL_CODE); -- 그것을 다시 LOC와 조인

-- 오라클 구문
SELECT EMP_NAME, DEPT_TITLE, LOCAL_NAME
FROM EMPLOYEE, DEPARTMENT, LOCATION
WHERE DEPT_CODE = DEPT_ID -- EMP + DEPT 조인
AND LOCATION_ID = LOCAL_CODE; -- (EMP + DEPT) + LOC 조인

-- 다중 조인 연습 문제

-- 직급이 대리이면서 아시아 지역에 근무하는 직원의
-- 사번, 이름, 직급명, 부서명, 근무 지역명, 급여 조회

-- EMP_ID (EMPLOYEE)
-- EMP_NAME (EMPLOYEE)
-- JOB_NAME (JOB)
-- DEPT_NAME (DEPARTMENT)
-- LOCAL_NAME (LOCATION)
-- SALARY (EMPLOYEE)

-- ANSI 표준
SELECT EMP_ID, EMP_NAME, JOB_NAME, DEPT_TITLE, LOCAL_NAME, SALARY
FROM EMPLOYEE JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
JOIN JOB USING (JOB_CODE)
JOIN LOCATION ON (LOCATION_ID = LOCAL_CODE)
WHERE JOB_NAME = '대리' AND LOCAL_NAME LIKE 'ASIA%';

-- 오라클 구문
SELECT EMP_ID, EMP_NAME, JOB_NAME, DEPT_TITLE, LOCAL_NAME, SALARY
FROM EMPLOYEE E, DEPARTMENT, JOB J, LOCATION
WHERE DEPT_CODE = DEPT_ID AND E.JOB_CODE = J.JOB_CODE
AND LOCATION_ID = LOCAL_CODE 
AND JOB_NAME = '대리' AND LOCAL_NAME LIKE 'ASIA%';









