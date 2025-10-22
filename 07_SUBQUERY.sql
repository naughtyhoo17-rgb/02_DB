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
 * - 다중열 서브쿼리 : 서브쿼리의 SELECT 절에 나열된 항목수가 여러 개일 때
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





