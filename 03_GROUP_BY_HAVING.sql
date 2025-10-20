/* SELECT문 해석 순서
 *
 * 5 : SELECT 컬럼명 AS 별칭, 계산식, 함수식
 * 1 : FROM 테이블명
 * 2 : WHERE 컬럼명 | 함수식 비교연산자 비교값
 * 3 : GROUP BY 그룹을 묶을 컬럼명
 * 4 : HAVING 그룹함수식 비교연산자 비교값
 * 6 : ORDER BY 컬럼명 | 별칭 | 컬럼순번 정렬방식(ASC/DESC) [NULLS FIRST | LAST];
 * 
 * */

---------------------------------------------------------------------------

-- * GROUP BY절
-- : 같은 값들이 여러개 기록된 컬럼을 가지고 같은 값들을 하나의 그룹으로 묶음


-- GROUP BY 컬럼명 | 함수식, ..

-- 여러개의 값을 묶어서 하나로 처리할 목적으로 사용함
-- 그룹으로 묶은 값에 대해서 SELECT절에서 그룹함수를 사용함

-- 그룹함수는 단 한개의 결과값만 산출하기 때문에 그룹이 여러개일 경우 오류 발생
-- 여러 개의 결과값을 산출하기 위해 그룹함수가 적용된 그룹의 기준을
-- ORDER BY절에 기술하여 사용


-- EMPLOYEE 테이블에서 부서코드, 부서 별 급여 합 조회

-- 1) 부서 코드만 조회
SELECT DEPT_CODE FROM EMPLOYEE; -- 23행

-- 2) 급여 합 조회
SELECT SUM(SALARY) FROM EMPLOYEE; -- 1행

SELECT DEPT_CODE, SUM(SALARY) FROM EMPLOYEE;
-- ORA-00937: 단일 그룹의 그룹 함수가 아닙니다 => 23개 행과 1개 행

SELECT DEPT_CODE, SUM(SALARY)
FROM EMPLOYEE
GROUP BY DEPT_CODE;
-- DEPT_CODE 컬럼을 그룹으로 묶어 그룹의 급여 합계 SUM(SALARY)를 구함

-- EMPLOYEE 테이블에서 (FROM절)
-- 직급 코드가 같은 사람의 (GROUP BY절 : 직급을 그룹으로 묶기)
-- 직급 코드, 급여 평균, 인원 수를 (SELECT절)
-- 직급 코드 오름차순으로 조회 (ORDER BY절)

SELECT JOB_CODE, ROUND(AVG(SALARY)), COUNT(*) 
FROM EMPLOYEE					-- COUNT == 행의 갯수 == 인원 수
GROUP BY JOB_CODE
ORDER BY JOB_CODE ASC;

-- EMPLOYEE 테이블에서 (FROM절)
-- 성별(남/여)과(GROUP BY절)
-- 각 성별 별 인원 수, 급여 합을 (SELECT절)
-- 인원 수 오름차순으로 조회 (ORDER BY절)
SELECT DECODE(SUBSTR(EMP_NO, 8, 1), '1', '남', '2', '여') "성별",
COUNT(*) "인원 수", SUM(SALARY) "급여 합"
FROM EMPLOYEE
GROUP BY DECODE(SUBSTR(EMP_NO, 8, 1), '1', '남', '2', '여')
-- GROUP BY에선 별칭 사용 불가 bcuz 해석 순서 상 아직 SELECT절이 해석되지 않아서 별칭 인식 x
ORDER BY "인원 수";
-- ORDER BY절에선 별칭 사용 가능 bcuz 순서 상 SELECT절 해석 이후

---------------------------------------------------------------------

-- * WHERE절 GROUP BY절 혼합 사용 *

-- ** => WHERE절은 각 컬럼값에 대한 조건을 따짐
-- 	  => HAVING절은 그룹에 대한 조건을 따짐! **

-- EMPLOYEE 테이블에서 (FROM절)
-- 부서 코드가 D5, D6인 부서의 (WHERE절 -> GROUP BY절)
-- 부서 코드, 평균 급여, 인원 수 조회 (SELECT절)
SELECT DEPT_CODE, ROUND(AVG(SALARY)), COUNT(*)
FROM EMPLOYEE
WHERE DEPT_CODE IN('D5', 'D6') -- 부서 코드가 D5, D6인
GROUP BY DEPT_CODE; -- 부서의 (WHERE절에서 구한 조건을 그룹으로 묶음)

-- EMPLOYEE 테이블에서
-- 2000년도 이후 입사자들의
-- 직급 코드, 직급 별 급여 합을 조회
-- 
SELECT JOB_CODE, SUM(SALARY)
FROM EMPLOYEE
WHERE EXTRACT(YEAR FROM HIRE_DATE) >= 2000
-- == TO_DATE('2000-01-01')
-- == SUBSTR(TO_CHAR(HIRE_DATE, 'YYYY'), 1, 4) >= '2000'
GROUP BY JOB_CODE;

-----------------------------------------------------------------

-- * 여러 컬럼을 묶어서 그룹으로 지정 가능 => 그룹 내 그룹 가능! *

-- EMPLOYEE 테이블에서
-- 부서 별로 같은 직급인 사원의 인원 수를 조회
-- 부서 코드 오름차순, 직급 코드 내림차순으로 정렬
-- 부서 코드, 직급 코드, 인원 수
SELECT DEPT_CODE, JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY DEPT_CODE, JOB_CODE -- DEPT_CODE로 그룹화(대분류)
							 -- 나눠진 그룹 내에서 JOB_CODE로 그룹화(소분류)
ORDER BY DEPT_CODE, JOB_CODE DESC;

-- <GROUP BY 사용 시 주의사항>
-- SELECT문에 GROUP BY절을 사용할 경우
-- SELECT절에 명시한 조회하려는 컬럼 중 그룹함수가 적용되지 않은 컬럼은
-- 모두 GROUP BY절에 작성 되어야!

--------------------------------------------------------------------

/* SELECT문 해석 순서
 *
 * 5 : SELECT 컬럼명 AS 별칭, 계산식, 함수식
 * 1 : FROM 테이블명
 * 2 : WHERE 컬럼명 | 함수식 비교연산자 비교값
 * 3 : GROUP BY 그룹을 묶을 컬럼명
 * 4 : HAVING 그룹함수식 비교연산자 비교값
 * 6 : ORDER BY 컬럼명 | 별칭 | 컬럼순번 정렬방식(ASC/DESC) [NULLS FIRST | LAST];
 * 
 * */

-- HAVING절 : 그룹함수로 구해 올 그룹에 대한 조건을 설정할 때 사용

-- EMPLOYEE 테이블에서
-- 부서 별 평균 급여가 3백 만원 이상인 부서의
-- 부서 코드, 평균 급여 조회
-- 부서 코드 오름차순 정렬
SELECT DEPT_CODE, ROUND(AVG(SALARY))
FROM EMPLOYEE
-- WHERE SALARY >= 3000000 => 개인의 급여가 3백 이상이라는 조건 (요구사항에 부적합)
GROUP BY DEPT_CODE
HAVING AVG(SALARY) >= 3000000
-- => DEPT_CODE 그룹 중 급여 평균이 3백 이상인 '그룹'만 조회 (요구사항 적합)
ORDER BY DEPT_CODE;

-- EMPLOYEE 테이블에서
-- 직급 별 인원 수가 5명 이하인 직급의
-- 직급 코드, 인원 수 조회
-- 단, 직급 코드 오름차순 정렬
SELECT JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY JOB_CODE
HAVING COUNT(*) <= 5 -- HAVING절에는 그룹함수가 반드시 작성 됨!
ORDER BY 1; -- JOB_CODE의 순서가 1번 째

--------------------------------------------------------------------

-- 집계 함수(ROLLUP, CUBE)
-- 그룹 별 산출 결과값의 집계를 계산하는 함수
-- (그룹 별로 중간 집계 결과를 추가할 수 있음)
-- * GROUP BY절에서만 사용할 수 있는 함수 *

-- ROLLUP : GROUP BY절에서 가장 먼저 작성된 컬럼의 중간 집계를 처리하는 함수

SELECT DEPT_CODE, JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY ROLLUP(DEPT_CODE , JOB_CODE)
ORDER BY 1; 


-- CUBE : GROUP BY절에 작성된 모든 컬럼의 중간 집계를 처리하는 함수
SELECT DEPT_CODE, JOB_CODE, COUNT(*)
FROM EMPLOYEE
GROUP BY CUBE(DEPT_CODE , JOB_CODE)
ORDER BY 1; 

---------------------------------------------------------------

/* SET OPERATOR (집합 연산자) 

-- 여러 SELECT의 결과(RESULT SET)를 하나의 결과로 만드는 연산자

- UNION (합집합) : 두 SELECT 결과를 하나로 합침
				  단, 중복은 한 번만 작성

- INTERSECT (교집합) : 두 SELECT 결과 중 중복되는 부분만 조회

- UNION ALL : UNION + INTERSECT 
			합집합에서 중복 부분 제거 X
							
- MINUS (차집합) : A에서 A,B 교집합 부분을 제거하고 조회

*/

-- EMPLOYEE 테이블에서
-- 부서 코드가 'D5'인 사원의 사번, 이름, 부서 코드, 급여 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE  = 'D5'
-- UNION
-- INTERSECT
-- UNION ALL
MINUS
-- 급여가 3백 만원 초과인 사원의 사번, 이름, 부서 코드, 급여 조회
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE SALARY > 3000000;

-- 주의사항!
-- 집합 연산자를 사용하기 위한 SELECT문들은
-- 조회하는 컬럼의 타입, 갯수 모두 동일해야 한다!
SELECT EMP_ID, EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
WHERE DEPT_CODE  = 'D5'
UNION
/*SELECT EMP_ID, EMP_NAME
FROM EMPLOYEE
WHERE SALARY >= 3000000;
-- ORA-01789: 질의 블록은 부정확한 수의 결과 열을 가지고 있습니다.
-- => 4개 vs. 2개 갯수가 맞지 않음 */
SELECT EMP_ID, EMP_NAME, DEPT_CODE, EMAIL
FROM EMPLOYEE
WHERE SALARY >= 3000000;
-- ORA-01790: 대응하는 식과 같은 데이터 유형이어야 합니다
-- => SALARY와 EMAIL 타입이 맞지 않음 => 같은 타입이기만 하면 ok

-- 서로 다른 테이블이더라도 (and also 컬럼이 달라도)
-- 컬럽의 타입, 갯수만 일치하면 집합 연산자 사용 가능!
SELECT EMP_ID, EMP_NAME FROM EMPLOYEE
UNION
SELECT DEPT_ID, DEPT_TITLE FROM DEPARTMENT;








