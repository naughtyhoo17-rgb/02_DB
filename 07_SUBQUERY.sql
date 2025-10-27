/*
 * SUBQUERY (서브쿼리 == 내부쿼리)
 * - 하나의 SQL문 안에 포함된 또 다른 SQL(SELECT)문
 * - 메인쿼리(== 외부쿼리, 기존쿼리)를 위해 보조 역할을 하는 쿼리문 
 * 
 * - 만약 메인쿼리가 SELECT문일 때,
 * 	SELECT, FROM, WHERE, HAVING절에서 사용 가능
 * */

-- 서브쿼리 예시 1.
-- 부서코드가 노옹철 사원과 같은 소속 직원의 이름, 부서 코드 조회

-- 1) 노옹철의 부서 코드 조회 (서브쿼리)
SELECT DEPT_CODE FROM EMPLOYEE WHERE EMP_NAME = '노옹철';

-- 2) 부서 코드 'D9'인 직원의 이름, 부서 코드 조회 (메인쿼리)
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D9';

-- 3) 부서 코드가 노옹철 사원과 같은 소속 직원 조회
-- => 위의 두 단계를 하나의 쿼리로!
SELECT EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = -- 외부쿼리
(SELECT DEPT_CODE FROM EMPLOYEE WHERE EMP_NAME = '노옹철'); -- 내부쿼리

-- 서브쿼리 예시 3.
-- 전 직원의 급여 평균보다 많은 급여를 받는 직원의
-- 사번, 이름, 직급코드, 급여 조회

-- 1) 전 직원의 급여 평균 조회하기 (서브쿼리)
SELECT CEIL(AVG(SALARY)) FROM EMPLOYEE; -- 3,047,663

-- 2) 급여가 3,047,663원 이상인 사원들의
-- 사번, 이름, 직급 코드, 급여 조회 (메인쿼리)
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= 3047663;

-- 3) 위 두 단계를 하나의 쿼리로
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY >= (SELECT CEIL(AVG(SALARY)) FROM EMPLOYEE);

-----------------------------------------------------------------

/* 서브쿼리 유형
 * 
 * - 단일행 (단일열) 서브쿼리 : 서브쿼리의 조회 결과값의 개수가 1개일 때
 * 
 * - 다중행 (단일열) 서브쿼리 : 서브쿼리의 조회 결과값의 개수가 여러 개일 때
 * 
 * - 다중열 서브쿼리 : 서브쿼리의 SELECT 절에 나열된 항목 수가 여러 개일 때
 * 
 * - 다중행 다중열 서브쿼리 : 조회 결과 행 수와 열 수가 여러 개일 때
 * 
 * - 상(호연)관 서브쿼리 : 서브쿼리가 만든 결과 값을 메인쿼리가 비교 연산할 때
 * 			메인쿼리 테이블의 값이 변경되면 서브쿼리의 결과값도 바뀌는 서브쿼리
 * 
 * - 스칼라 서브쿼리 : 상관 쿼리이면서 결과값이 하나인 서브쿼리
 * 
 * ** 서브쿼리 유형에 따라 서브쿼리 앞에 붙는 연산자가 다름 ** 
 * 
 * */			
			
			
-- 1. 단일행 서브쿼리 (SINGLE ROW SUBQUERY)
--    서브쿼리의 조회 결과값의 개수가 1개인 서브쿼리
--    단일행 서브쿼리 앞에는 비교 연산자 사용 가능
--    < , >, <= , >= , = , != / <> / ^=			

-- 전 직원의 급여 평균/보다 초과하여 급여를 받는 직원의
--		(서브쿼리)			(나머지 메인쿼리)
-- 이름, 직급명, 부서명, 급여를 직급 순으로 정렬하여 조회

-- 서브쿼리
SELECT CEIL(AVG(SALARY)) FROM EMPLOYEE; -- 3,047,663 단일행(단일열)

SELECT EMP_NAME, JOB_NAME, DEPT_TITLE, SALARY
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE SALARY > (SELECT CEIL(AVG(SALARY)) FROM EMPLOYEE)
ORDER BY JOB_CODE; -- 정렬기준은 SELECT절에 없는 컬럼도 가능! (테이블 상 존재하는 컬럼이면 ok)

-- 가장 적은 급여를 받는 직원의
-- 사번, 이름, 직급명, 부서코드, 급여, 입사일 조회

SELECT EMP_ID, EMP_NAME, JOB_NAME, DEPT_CODE, SALARY, HIRE_DATE
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
WHERE SALARY = (SELECT MIN(SALARY) FROM EMPLOYEE);

-- 노옹철 사원의 급여보다 초과하여 받는 직원의
-- 사번, 이름, 부서명, 직급명, 급여 조회

-- SELECT SALARY FROM EMPLOYEE WHERE EMP_NAME = '노옹철'

SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, SALARY
FROM EMPLOYEE JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE SALARY > (SELECT SALARY FROM EMPLOYEE WHERE EMP_NAME = '노옹철');

-- 부서별(부서가 없는 사람 포함) 급여 합계 중 가장 큰 부서의
-- 부서명, 급여 합계 조회

-- 1) 부서별 급여 합 중 가장 큰 값 조회 (서브쿼리)
SELECT MAX(SUM(SALARY)) FROM EMPLOYEE
GROUP BY DEPT_CODE; -- 17,700,000 단일행(단일열)

-- 2) 서브쿼리에 해당하는 부서의 부서명, 급여 합계 조회
SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
GROUP BY DEPT_TITLE
HAVING SUM(SALARY) = 17700000;

-- 3) 위의 두 쿼리 합쳐 하나의 쿼리로!
SELECT DEPT_TITLE, SUM(SALARY)
FROM EMPLOYEE
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
GROUP BY DEPT_TITLE
HAVING SUM(SALARY) = (SELECT MAX(SUM(SALARY))
					  FROM EMPLOYEE
					  GROUP BY DEPT_CODE);

-------------------------------------------------------------------
-------------------------------------------------------------------

-- 2. 다중행 서브쿼리 (MULTI ROW SUBQUERY)
--    서브쿼리의 조회 결과 값의 개수가 여러 행일 때

/* 
 * >> ** 다중행 서브쿼리 앞에는 일반 비교연산자 사용 X **
 * 
 * - IN / NOT IN : 여러 개의 결과값 중에서 한 개라도 일치하는 값이 있다면
 * 				 혹은 없다면 이라는 의미 (가장 많이 사용!)
 * 
 * - > ANY, < ANY : 여러개의 결과값 중에서 한 개라도 큰 / 작은 경우
 * 			=> 가장 작은 값 보다 큰가? / 가장 큰 값 보다 작은가?
 * 
 * - > ALL, < ALL : 여러개의 결과값의 모든 값 보다 큰 / 작은 경우
 * 			=> 가장 큰 값 보다 큰가? / 가장 작은 값 보다 작은가?
 * 
 * - EXISTS / NOT EXISTS : 값이 존재하는가? / 존재하지 않는가?
 * 
 * 
 * */


-- 부서 별 최고 급여를 받는 직원의
-- 이름, 직급, 부서, 급여를
-- 부서 순으로 정렬하여 조회

-- 부서 별 최고 급여 (서브쿼리)
SELECT MAX(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE; -- 7행 => 다중행

SELECT EMP_NAME, JOB_NAME, DEPT_TITLE, SALARY
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE SALARY IN (SELECT MAX(SALARY)
				 FROM EMPLOYEE
				 GROUP BY DEPT_CODE)
ORDER BY DEPT_CODE;

-- 사수에 해당하는 직원에 대해 조회
-- 사번, 이름, 부서명, 직급명, 구분(사수/사원)

-- * 사수 == MANAGER_ID 컬럼에 작성된 사번

-- 1) 사수에 해당하는 사원의 사원 번호 조회
SELECT DISTINCT MANAGER_ID
FROM EMPLOYEE WHERE MANAGER_ID IS NOT NULL;

-- 2) 직원의 사번, 이름, 부서명, 직급명 조회
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);

-- 3) 사수에 해당하는 직원의 정보 조회 (구분 '사수')
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사수' 구분
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID IN (SELECT DISTINCT MANAGER_ID
				 FROM EMPLOYEE
				 WHERE MANAGER_ID IS NOT NULL);

-- 4) 사수가 아닌 사원에 해당하는 직원의 정보 조회 (구분 '사원')
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사원' 구분
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID NOT IN (SELECT DISTINCT MANAGER_ID
				 	 FROM EMPLOYEE
				 	 WHERE MANAGER_ID IS NOT NULL);

-- 5) 3, 4 단계의 조회 결과를 하나로 조회

-- i) 집합 연산자 사용 (UNION, 합집합)
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사수' 구분
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID IN (SELECT DISTINCT MANAGER_ID
				 FROM EMPLOYEE
				 WHERE MANAGER_ID IS NOT NULL)
UNION
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME, '사원' 구분
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE EMP_ID NOT IN (SELECT DISTINCT MANAGER_ID
				 	 FROM EMPLOYEE
				 	 WHERE MANAGER_ID IS NOT NULL);

-- ii) 선택 함수 사용 (DECODE / CASE WHEN)
SELECT EMP_ID, EMP_NAME, DEPT_TITLE, JOB_NAME,
CASE WHEN EMP_ID IN (SELECT DISTINCT MANAGER_ID
				 	 FROM EMPLOYEE
				 	 WHERE MANAGER_ID IS NOT NULL)
				 	 THEN '사수'
				 	 ELSE '사원'
				 END 구분
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);

-- 대리 직급의 직원들 중 과장 직급의 최소 급여보다 많이 받는 직원의
-- 사번, 이름, 직급명, 급여 조회

-- 가장 작은 값보다 큰가? -- > ANY 사용

-- 1) 과장 직급의 급여 조회 (서브쿼리)
SELECT SALARY FROM EMPLOYEE
JOIN JOB USING(JOB_CODE)
WHERE JOB_NAME = '과장'; -- 3행

-- 2) 직급이 대리인 직원들의 사번, 이름, 직급명, 급여 조회 (메인쿼리)
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '대리'

-- 3) 하나의 쿼리로!

 -- 방법i) ANY 이용(다중행)
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '대리'
AND SALARY > ANY (SELECT SALARY FROM EMPLOYEE
				  JOIN JOB USING(JOB_CODE)
				  WHERE JOB_NAME = '과장');

 -- 방법ii) MIN 이용(단일행)
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '대리'
AND SALARY > (SELECT MIN(SALARY)
			  FROM EMPLOYEE
			  JOIN JOB USING(JOB_CODE)
			  WHERE JOB_NAME = '과장');
 
 
-- 차장 직급의 급여 중 가장 큰 값보다 많이 받는 과장 직급의 직원
-- 사번, 이름, 직급, 급여 조회

-- 가장 큰 값보다 큰가? -- > ALL 사용
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '과장'
AND SALARY > ALL (SELECT SALARY FROM EMPLOYEE
				  JOIN JOB USING(JOB_CODE)
				  WHERE JOB_NAME = '차장');

-- 단일행
SELECT EMP_ID, EMP_NAME, JOB_NAME, SALARY
FROM EMPLOYEE JOIN JOB USING (JOB_CODE)
WHERE JOB_NAME = '과장'
AND SALARY > (SELECT MAX(SALARY)
			  FROM EMPLOYEE
			  JOIN JOB USING(JOB_CODE)
			  WHERE JOB_NAME = '차장');


-- 서브쿼리 중첩 사용 (응용!)

-- LOCATION TABLE에서 NATIONAL_CODE가 'KO'인 경우의 LOCAL_CODE와
-- DEPARTMENT 테이블의 LOCATION_ID와 동일한 DEPT_ID가
-- EMPLOYEE 테이블의 DEPT_CODE와 동일한 사원의 이름과 부서코드 조회

-- 1) LOCATION TABLE에서 NATIONAL_CODE가 'KO'인 경우의 LOCAL_CODE (서브쿼리 1)

SELECT * FROM LOCATION;

SELECT LOCAL_CODE FROM LOCATION
WHERE NATIONAL_CODE = 'KO'; -- 'L1'


-- 2) DEPARTMENT 테이블의 위의 결과(L1)와
-- 	동일한 LOCATION_ID을 가지고 있는 DEPT_ID 조회 (서브쿼리 2)
SELECT DEPT_ID FROM DEPARTMENT
WHERE LOCATION_ID = (SELECT LOCAL_CODE FROM LOCATION
WHERE NATIONAL_CODE = 'KO'); -- 서브쿼리 1을 활용한 서브쿼리 2

-- 3) EMPLOYEE 테이블의 위의 결과와 동일한 DEPT_CODE를 가진 사원의
--	이름, 부서코드 조회 (메인쿼리)
SELECT EMP_NAME, DEPT_CODE FROM EMPLOYEE
WHERE DEPT_CODE IN (SELECT DEPT_ID FROM DEPARTMENT
-- 다중행은 = 사용 불가 thus IN 사용
					WHERE LOCATION_ID = (SELECT LOCAL_CODE
					FROM LOCATION WHERE NATIONAL_CODE = 'KO'));

---------------------------------------------------------------------------

-- 3.(단일행) 다중열 서브쿼리
-- 서브쿼리 SELECT절에 나열된 컬럼 수가 여러 개일 때

-- 퇴사한 여직원과 같은 부서, 같은 직급에 해당하는 
-- 사원의 이름, 직급코드, 부서코드, 입사일 조회

-- 1) 퇴사한 여직원 조회 (서브쿼리)
SELECT DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE ENT_YN = 'Y' 
AND SUBSTR(EMP_NO, 8, 1) = '2'; -- D8, J6 (이태림)

-- 2) 퇴사한 여직원과 같은 부서, 같은 직급인 사원 조회

-- 방법 i) 단일행 서브쿼리 2개 사용해서 조회
SELECT EMP_NAME, JOB_CODE, DEPT_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE DEPT_CODE = (SELECT DEPT_CODE
				   FROM EMPLOYEE
				   WHERE ENT_YN = 'Y' 
				   AND SUBSTR(EMP_NO, 8, 1) = '2')
AND JOB_CODE = (SELECT JOB_CODE
				FROM EMPLOYEE
				WHERE ENT_YN = 'Y' 
				AND SUBSTR(EMP_NO, 8, 1) = '2');


-- 방법 ii) 다중열 서브쿼리 사용
--> WHERE절에 작성된 컬럼 순서에 맞게 서브쿼리의 조회된 컬럼과
--	비교하여 일치하는 행만 조회 (컬럼 순서 중요!!)

SELECT EMP_NAME, JOB_CODE, DEPT_CODE, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (SELECT DEPT_CODE, JOB_CODE
							FROM EMPLOYEE
							WHERE ENT_YN = 'Y' 
							AND SUBSTR(EMP_NO, 8, 1) = '2');

-- 다중열 서브쿼리 연습문제
-- 1. 노옹철 사원과 같은 부서, 같은 직급인 사원을 조회 (단, 노옹철 제외) 
-- 사번, 이름, 부서코드, 직급코드, 부서명, 직급명 조회

SELECT DEPT_CODE, JOB_CODE 
FROM EMPLOYEE
WHERE EMP_NAME = '노옹철'; -- (다중열 서브쿼리)

SELECT EMP_ID, EMP_NAME, DEPT_CODE, JOB_CODE, DEPT_TITLE, JOB_NAME
FROM EMPLOYEE JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE (DEPT_CODE, JOB_CODE) = (SELECT DEPT_CODE, JOB_CODE 
	  							FROM EMPLOYEE
								WHERE EMP_NAME = '노옹철')
AND EMP_NAME != '노옹철';

-- 2. 2000년도에 입사한 사원의 부서와 직급이 같은 사원을 조회
-- 사번, 이름, 부서코드, 직급코드, 입사일 조회

SELECT DEPT_CODE, JOB_CODE FROM EMPLOYEE
WHERE EXTRACT(YEAR FROM HIRE_DATE) = '2000'; -- 서브쿼리

SELECT EMP_ID, EMP_NAME, DEPT_CODE, JOB_CODE, HIRE_DATE 
FROM EMPLOYEE
WHERE (DEPT_CODE, JOB_CODE) = (SELECT DEPT_CODE, JOB_CODE 
						   FROM EMPLOYEE
						   WHERE EXTRACT(YEAR FROM HIRE_DATE) = '2000')
AND EMP_NAME <> '유재식';

-- 3. 77년생 여자 사원과 동일한 부서이면서 동일한 사수를 가지고 있는 사원 조회
-- 사번, 이름, 부서코드, 사수번호, 주민번호, 입사일 조회

SELECT DEPT_CODE, MANAGER_ID FROM EMPLOYEE
WHERE EMP_NO LIKE '77%' 
AND SUBSTR(EMP_NO, 8, 1) = '2'; -- 서브쿼리

SELECT EMP_ID, EMP_NAME, DEPT_CODE, EMP_NO, HIRE_DATE
FROM EMPLOYEE
WHERE (DEPT_CODE, MANAGER_ID) = (SELECT DEPT_CODE, MANAGER_ID 
								 FROM EMPLOYEE
								 WHERE EMP_NO LIKE '77%' 
								 AND SUBSTR(EMP_NO, 8, 1) = '2')
AND EMP_NAME != '전지연';

------------------------------------------------------------------------

-- 4. 다중행 다중열 서브쿼리 
-- 서브쿼리 조회 결과 행 수와 열 수가 여러 개일 때

-- 본인이 소속된 직급의 평균 급여를 받고 있는 직원의
-- 사번, 이름, 직급코드, 급여 조회 
-- 단, 급여와 급여 평균은 만원 단위로 계산! (절삭 TRUNC() 이용)

-- 1) 직급별 평균 급여 (서브쿼리)
SELECT JOB_CODE, TRUNC(AVG(SALARY), -4) "직급별 평균 급여" -- 만원 단위로 절삭
FROM EMPLOYEE 
GROUP BY JOB_CODE;

-- 2) 직급별 평균 급여를 받고있는 직원의 사번, 이름, 직급코드, 급여 조회 (메인 + 서브)
SELECT EMP_ID, EMP_NAME, JOB_CODE, SALARY
FROM EMPLOYEE
WHERE (JOB_CODE, SALARY) IN (SELECT JOB_CODE, TRUNC(AVG(SALARY), -4)
							 FROM EMPLOYEE 
							 GROUP BY JOB_CODE);
-- (JOB_CODE, SALARY) : 다중열 특징
-- IN : 다중행 특징 
-- => 두 개의 특징을 동시에 가짐

---------------------------------------------------------------

-- 5. 상[호연]관 서브쿼리                        
-- 상관 쿼리는 메인쿼리가 사용하는 테이블값을 서브쿼리가 이용해서 결과를 만듦
-- 메인쿼리의 테이블값이 변경되면 서브쿼리의 결과값도 바뀌게 되는 구조

-- 상관쿼리는 먼저 메인쿼리 한 행을 조회하고
-- 해당 행이 서브쿼리의 조건을 충족하는지 확인하여 SELECT를 진행함

-- ** 해석순서가 기존 서브쿼리와 다르게
-- 메인쿼리 1행 -> 1행에 대한 서브쿼리 수행
-- 메인쿼리 2행 -> 2행에 대한 서브쿼리 수행
-- ...
-- 메인쿼리의 행의 수 만큼 서브쿼리가 생성되어 진행됨

-- * 상관 서브쿼리는 행마다 비교/검증이 필요할 때 사용!

-- 상관쿼리 예시 1.
-- 직급별 급여 평균보다 급여를 많이 받는 직원의 이름, 직급코드, 급여 조회

-- 메인쿼리
SELECT EMP_NAME, JOB_CODE, SALARY 
FROM EMPLOYEE;

-- 서브쿼리
SELECT AVG(SALARY)
FROM EMPLOYEE
WHERE JOB_CODE = 'J1';

-- 상관쿼리
SELECT EMP_NAME, JOB_CODE, SALARY 
FROM EMPLOYEE MAIN
WHERE SALARY > (SELECT AVG(SALARY)
				FROM EMPLOYEE SUB
				WHERE MAIN.JOB_CODE = SUB.JOB_CODE);

-- 상관쿼리 예시 2.
-- 부서별 입사일이 가장 빠른 사원의
-- 사번, 이름, 부서코드, 부서명(NULL이면 소속 없음), 직급명, 입사일 조회
-- 입사일 빠른 순으로 정렬(단, 퇴사한 직원은 제외)

-- 메인쿼리
SELECT EMP_ID, EMP_NAME, DEPT_CODE,
NVL(DEPT_TITLE, '소속 없음'), JOB_NAME, HIRE_DATE
FROM EMPLOYEE JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
ORDER BY HIRE_DATE;

-- 서브쿼리
SELECT MIN(HIRE_DATE) 
FROM EMPLOYEE
WHERE DEPT_CODE = 'D1';

-- 상관 쿼리
SELECT EMP_ID, EMP_NAME, DEPT_CODE,
NVL(DEPT_TITLE, '소속 없음'), JOB_NAME, HIRE_DATE
FROM EMPLOYEE MAIN JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
WHERE HIRE_DATE = 
(SELECT MIN(HIRE_DATE) 
FROM EMPLOYEE SUB
WHERE ENT_YN = 'N' 
AND MAIN.DEPT_CODE = SUB.DEPT_CODE)
ORDER BY HIRE_DATE;

---------------------------------------------------------------

-- 6. 스칼라 서브쿼리
-- SELECT절에 사용되는 서브쿼리로 결과를 1행만 반환
-- SQL에서 단일 값을 '스칼라' 라고함
-- 즉, SELECT절에 작성되는 단일행 단일열 서브쿼리를 스칼라 서브쿼리라고 함!

-- 스칼라 서브쿼리 예시1.
-- 모든 직원의 이름, 직급코드, 급여, 전체 사원 중 가장 높은 급여와의 차를 조회하라
SELECT EMP_NAME, JOB_CODE, SALARY,
( SELECT MAX(SALARY) FROM EMPLOYEE ) - SALARY "급여 차"
FROM EMPLOYEE;

-- 스칼라 서브쿼리 예시2.
-- 모든 사원의 이름, 직급코드, 급여,
-- 각 직원들이 속한 직급의 급여 평균을 조회

-- 스칼라 + 상관쿼리
SELECT EMP_NAME, JOB_CODE, SALARY,
(SELECT CEIL(AVG(SALARY)) 
FROM EMPLOYEE SUB
WHERE MAIN.JOB_CODE = SUB.JOB_CODE) "직급별 평균"
FROM EMPLOYEE MAIN
ORDER BY JOB_CODE;

-- 여기까지 서브쿼리, 이후엔 서브쿼리 관련 추가적 내용
---------------------------------------------------------------

-- 7. 인라인 뷰 (INLINE-VIEW)
-- FROM 절에서 서브쿼리를 사용하는 경우
-- 서브쿼리가 만든 결과의 집합(RESULT SET)을 테이블 대신 사용

-- 서브쿼리
SELECT EMP_NAME 이름, DEPT_TITLE 부서
FROM EMPLOYEE
JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID);

-- 부서가 기술지원부인 모든 값 조회
SELECT * FROM 
(SELECT EMP_NAME 이름, DEPT_TITLE 부서
FROM EMPLOYEE
JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID))
WHERE 부서 = '기술지원부';
-- REUSLT SET을 테이블로 사용하는 것이기 때문에 컬럼명이 어떻게 되어있는지 확인!
-- 위의 경우에는 부서라는 별칭을 주었기 때문에 부서 = '기술지원부'라고 작성
-- '부서'가 컬럼명인 셈

-- 인라인뷰를 활용한 TOP-N 분석

-- 전 직원 중 급여가 높은 상위 5명의 순위, 이름, 급여 조회

-- ROWNUM 컬럼 : 행 번호를 나타내는 가상 컬럼
-- SELECT, WHERE, ORDER BY절에서 사용 가능

/* 3 */ SELECT ROWNUM 순위, EMP_NAME 이름, SALARY 급여
/* 1 */ FROM EMPLOYEE
/* 2 */ WHERE ROWNUM <= 5
/* 4 */ ORDER BY SALARY DESC;
--> SELECT문의 해석 순서 때문에 급여 상위 5명이 아닌,
-- 	조회 순서 상위 5명 끼리의 급여 순위 정렬되어 조회

--> 인라인 뷰를 이용해서 해결 가능!

-- 1) 이름과 급여를 급여 내림차순으로 조회한 결과를 인라인뷰 사용
--> FROM 절에 작성되기 때문에 해석 1순위
SELECT EMP_NAME, SALARY
FROM EMPLOYEE
ORDER BY SALARY DESC;

-- 2) 메인쿼리 조회 시 인라인 뷰를 이용하여 급여 상위 5명까지 조회
SELECT ROWNUM 순위, EMP_NAME, SALARY
FROM (SELECT EMP_NAME, SALARY FROM EMPLOYEE ORDER BY SALARY DESC)
-- FROM절이 해석 1순위이기 때문에 전체 직원의 SALARY 내림차순 정렬
WHERE ROWNUM <= 5; -- 해석순위 2위인 WHERE절에서 가상컬럼의 1~5행까지만 조회

-- 급여 평균이 3위 안에 드는 부서의 부서코드, 부서명, 평균 급여 조회
-- 인라인 뷰 + GROUP BY

SELECT DEPT_CODE, DEPT_TITLE, CEIL(AVG(SALARY)) 평균급여
FROM EMPLOYEE 
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
GROUP BY DEPT_CODE, DEPT_TITLE
ORDER BY 평균급여 DESC;

SELECT ROWNUM 순위, DEPT_CODE, DEPT_TITLE, 평균급여
FROM 
(SELECT DEPT_CODE, DEPT_TITLE, CEIL(AVG(SALARY)) 평균급여
FROM EMPLOYEE 
LEFT JOIN DEPARTMENT ON (DEPT_CODE = DEPT_ID)
GROUP BY DEPT_CODE, DEPT_TITLE
ORDER BY 평균급여 DESC)
WHERE ROWNUM <= 3;

---------------------------------------------------------------

-- 8. WITH
-- 서브쿼리에 이름 붙여주고 사용 시 그 이름을 통해 호출
-- 인라인뷰로 사용될 서브 쿼리에 주로 사용하며, 실행 속도가 빨라진다는 장점이 있음

-- 전 직원의 급여 순위 
-- 순위, 이름, 급여 조회 (10위까지만)

WITH TOP_SAL AS
(SELECT EMP_NAME, SALARY
FROM EMPLOYEE
ORDER BY SALARY DESC)
SELECT ROWNUM, EMP_NAME, SALARY
FROM TOP_SAL
WHERE ROWNUM <= 10;

---------------------------------------------------------------

-- 9. RANK() OVER(정렬 순서) / DENSE_RANK() OVER(정렬 순서)

-- RANK() OVER : 동일한 순위 이후의 등수를 동일한 인원 수 만큼 건너 뛰고 순위 계산
-- ex) 공동 1위가 2명이면 다음 순위는 3위로 조회됨

-- 사원 별 급여 순위
SELECT RANK() OVER(ORDER BY SALARY DESC) 순위, EMP_NAME, SALARY
FROM EMPLOYEE;
-- 19	전형돈	2000000
-- 19	윤은해	2000000
-- 21	박나라	1800000

-- DENSE_RANK() OVER : 동일한 순위 이후의 등수를 이후 순위로 계산 (건너 뛰지 않는 것)
-- ex) 공동 1위가 2명이어도 다음 순위는 2위

-- 사원 별 급여 순위
SELECT DENSE_RANK() OVER(ORDER BY SALARY DESC) 순위, EMP_NAME, SALARY
FROM EMPLOYEE;
-- 19	전형돈	2000000
-- 19	윤은해	2000000
-- 20	박나라	1800000



