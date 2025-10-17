/*
 * SELECT (DML 또는 DQL) : 조회
 * 
 * - 데이터를 조회(SELECT)하면 조건에 맞는 행들이 조회됨.
 * 	이 때, 조회된 행들의 집합을 "RESULT SET" 이라고 한다.
 * 
 * - RESULT SET은 0개 이상의 행을 포함
 * => why 0개? 조건에 맞는 행이 아예 없을수도 있음
 * 
 * [작성법]
 * SELECT 컬럼명 FROM 테이블명;
 * => 테이블의 특정 컬럽 조회
 * 
 */

SELECT * FROM EMPLOYEE;
-- * : ALL, 모든, 전부
-- => EMPLOYEE 테이블에서 모든 컬럽을 조회하겠다는 명령어.

-- EMPLOYEE 테이블에서 사번, 직원 이름, 휴대폰 번호 3개 컬럼만 조회
SELECT EMP_ID, EMP_NAME, PHONE FROM EMPLOYEE;
-- ORA-00904: "PHONE2": 부적합한 식별자

-----------------------------------------------------------

-- <컬럼값 산술 연산>
-- 컬럼값 : 테이블 내 한 칸(== 한 셀)에 작성된 값(DATA 자체)

-- EMPLOYEE 테이블에서 모든 사원의 사번, 이름, 급여, 연봉 조회
SELECT EMP_ID, EMP_NAME, SALARY, SALARY * 12 FROM EMPLOYEE;

SELECT EMP_NAME + 10 FROM EMPLOYEE;
-- ORA-01722: 수치가 부적합합니다
-- 산술 연산은 숫자타입(NUMBER)만 가능!

SELECT '같음' FROM DUAL WHERE 1 = '1';
-- DUAL(DUmmy tAbLe) : 가짜 테이블(임시 조회용 테이블)

-- 문자열 타입이어도 저장된 값이 숫자면 자동 형변환되어 연산 가능
SELECT EMP_ID + 10 FROM EMPLOYEE;
-- ID는 VARCHAR2형태인데 실제 숫자로만 구성되어 있어 산술 연산 가능

--------------------------------------------------------------

-- 날짜(DATE) 타입 조회

-- EMPLOYEE 테이블에서 이름, 입사일, 오늘 날짜 조회
SELECT EMP_NAME, HIRE_DATE, SYSDATE FROM EMPLOYEE;

-- 2025-10-17 10:34:56.000
-- SYSDATE : 시스템 상의 현재 시간(날짜)를 나타내는 상수

SELECT SYSDATE FROM DUAL;

-- 날짜 + 산술연산 (+,-)
SELECT SYSDATE -1, SYSDATE, SYSDATE + 1 FROM DUAL;
-- 날짜에 +/- 연산 시 일(day) 단위로 계산됨

--------------------------------------------------------------

-- <컬럼 별칭 지정>
-- 컬럼명 AS 별칭 : 별칭 띄어쓰기 x, 특수문자 x, only 문자만 ok
-- 컬럼명 AS "별칭" : 별칭 띄어쓰기 o, 특수문자 o, 당연히 문자만도 ok
-- AS 생략 가능

SELECT SYSDATE -1 "어제", SYSDATE AS 오늘, SYSDATE + 1 내일 FROM DUAL;

--------------------------------------------------------------

-- JAVA 리터럴 : 값 자체를 의미
-- DB 리터럴 : 임의로 지정한 값을 기존 테이블에 존재하던 값처럼 사용하는 것
-- => DB 리터럴 표기법 : '' 홑따옴표
SELECT EMP_NAME, SALARY, '원 입니다' FROM EMPLOYEE;

--------------------------------------------------------------

-- DISTINCT : 조회 시 컬럼에 포함된 중복값을 한 번만 표기
-- 주의사항 1) DISTINCT 구문은 SELECT 마다 딱 한 번씩만 작성 가능
-- 주의사항 2) DISTINCT 구문은 SELECT 바로 다음으로 제일 앞 쪽에 작성해야

SELECT DISTINCT DEPT_CODE, JOB_CODE FROM EMPLOYEE;

--------------------------------------------------------------
 
-- 3. SELECT 절 : SELECT 컬럼명
-- 1. FROM 절 : FROM 테이블명
-- 2. WHERE 절(조건절) : WHERE 컬럼명 연산자 값;
-- 4. ORDER BY 컬럼명 | 별칭 | 컬럼 순서 [ASC | DESC] [NULLS FIRST | LAST]

-- EMPLOYEE 테이블에서 / 급여가 3백 만원 초과인 사원의 / 사번, 이름, 급여, 부서코드 조회
--		(FROM 절)			(WHERE 절)				(SELECT 절)

SELECT EMP_ID, EMP_NAME, SALARY, DEPT_CODE
FROM EMPLOYEE
WHERE SALARY > 3000000;

-- 비교 연산자 : >, <, >=, <=, =(not ==), !=, <>(같지 않다)
-- 대입 연산자 : :=

-- EMPLOYEE 테이블에서 / 부서코드가 'D9'인 사원의 / 사번, 이름, 부서코드, 직급코드 조회
--		(FROM 절)			(WHERE 절)			(SELECT 절)

SELECT EMP_ID, EMP_NAME, DEPT_CODE, JOB_CODE
FROM EMPLOYEE
WHERE DEPT_CODE = 'D9';

--------------------------------------------------------------

-- 논리 연산자(AND / OR)
-- EMPLOYEE 테이블에서 급여가 3백 만원 미만
-- 또는 5백 만원 이상인 사원의 사번, 이름, 급여, 전화번호 조회

SELECT EMP_ID, EMP_NAME, SALARY, PHONE
FROM EMPLOYEE
WHERE SALARY >= 5000000 OR SALARY < 3000000;

-- EMPLOYEE 테이블에서 급여가 3백 만원 이상이고
-- 5백 만원 미만인 사원의 사번, 이름, 급여, 전화번호 조회

SELECT EMP_ID, EMP_NAME, SALARY, PHONE
FROM EMPLOYEE
WHERE SALARY >= 3000000 AND SALARY < 5000000;

-- BETWEEN A AND B : A 이상 B 이하

-- 3백 만 이상 6백 만 이하

SELECT EMP_ID, EMP_NAME, SALARY, PHONE
FROM EMPLOYEE
WHERE SALARY BETWEEN 3000000 AND 6000000;

-- NOT BETWEEN A AND B : A 미만 B 초과 (BETWEEN 이외 범위)
SELECT EMP_ID, EMP_NAME, SALARY, PHONE
FROM EMPLOYEE
WHERE SALARY NOT BETWEEN 3000000 AND 6000000;

-- 날짜(DATE)에 BETWEEN 이용하기 => 홑따옴표 안에 날짜 입력
-- EMPLOYEE 테이블에서 입사일이 1990-01-01 ~ 1999-12-31 사이인 직원의
-- 이름, 입사일 조회

SELECT EMP_NAME, HIRE_DATE
FROM EMPLOYEE
WHERE HIRE_DATE BETWEEN '1990-01-01' AND '1999-12-31'; 

--------------------------------------------------------------


-- LIKE 연산자 : 비교하려는 값이 특정 패턴을 만족하면 조회하는 연산자

-- [작성법]
-- WHERE 컬럼명 LIKE '패턴이 적용된 값'

-- LIKE의 패턴을 나타내는 문자
-- '%' : 포함
-- '_' : 글자 수

-- '%' 예시
-- 'A%' : A로 시작하는 문자열
-- '%A' : A로 끝나는 문자열
-- '%A%' : A가 어디있든 A를 포함하는 문자열

-- '_' 예시
-- 'A_' : A로 시작하는 두 글자 문자열 (A 포함)
-- '____A' : A로 끝나는 다섯 글자 문자열
-- '__A__' : 세 번째 글자가 A인 다섯 글자 문자열
-- '_____' : 뭐든 다섯 글자 문자열

-- EMPLOYEE 테이블에서 성이 '전'씨인 사원의 사번, 이름 조회

SELECT EMP_ID, EMP_NAME FROM EMPLOYEE WHERE EMP_NAME LIKE '전%';

-- EMPLOYEE 테이블에서 전화번호가 010으로 시작하지 않는 사원의 사번, 이름, 전화번호 조회

SELECT EMP_ID, EMP_NAME, PHONE FROM EMPLOYEE WHERE PHONE NOT LIKE '010%';

-- EMPLOYEE 테이블에서 EMAIL에 _앞에 글자가 세 글자인 사원의 이름 이메일 조회

SELECT EMP_NAME, EMAIL FROM EMPLOYEE WHERE EMAIL LIKE '____%'; 

-- ESCAPE 문자 
-- ESCAPE 문자 뒤에 작성된 _는 일반 문자로 탈출한다는 뜻
-- #, ^

SELECT EMP_NAME, EMAIL FROM EMPLOYEE WHERE EMAIL LIKE '___^_%' ESCAPE '^';

-- <연습문제>
-- EMPLOYEE 테이블에서 EMAIL의 '_' 앞이 4 글자이면서
-- 부서코드가 'D9' 또는 'D6'이고
-- 입사일이 1990-01-01 ~ 2000-12-31 이고
-- 급여가 270만원 이상인 사원의
-- 사번, 이름, 이메일, 부서코드, 입사일, 급여 조회
-- Hint! AND 가 OR보다 우선순위가 높다, () 사용으로 우선 연산 가능

SELECT EMP_ID, EMP_NAME, EMAIL, DEPT_CODE, HIRE_DATE, SALARY
FROM EMPLOYEE
WHERE EMAIL LIKE '____^_%' ESCAPE '^'
AND (DEPT_CODE = 'D9' OR DEPT_CODE = 'D6')
AND HIRE_DATE BETWEEN '1990-01-01' AND '2000-12-31'
AND SALARY >= 2700000;

-- 연산자 우선순위
/* 1. 산술 연산자 (+, -, *, /)
 * 2. 연결 연산자 (||)
 * 3. 비교 연산자 (>, <, >=, <=, !=, <>)
 * 4. IS NULL / IS NOT NULL, LIKE, IN / NOT IN
 * 5. BETWEEN AND / NOT BETWEEN
 * 6. NOT(논리 연산자) => 부정의 의미
 * 7. AND
 * 8. OR
 */

--------------------------------------------------------------

/*
 * IN 연산자
 * 
 * 비교하려는 값과 목록에 작성된 값 중 일치하는 것이 있으면 조회하는 연산자
 * 
 * [작성법]
 * WHERE 컬럼명 IN(값1, 값2, 값3 ...)
 * 
 * WHERE 컬럼명 = '값1' OR 컬럼명 = '값2' ...
 * 
 */

-- EMPLOYEE 테이블에서 / 부서코드가 D1, D6, D9인 사원의 / 사번, 이름, 부서코드 조회
-- 		(FROM절)				(WHERE절)				(SELECT절)

SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE IN('D1','D6','D9'); -- 9명

-- NOT IN
SELECT EMP_ID, EMP_NAME, DEPT_CODE
FROM EMPLOYEE
WHERE DEPT_CODE NOT IN('D1','D6','D9') -- 12명
OR DEPT_CODE IS NULL; -- NULL 2명 포함 => 즉 D1, D6, D9 아닌 사람 모두 나옴

--------------------------------------------------------------

/*
 * IS NULL / IS NOT NULL
 * 
 * IS NULL : NULL인 경우 조회
 * IS NOT NULL : NULL이 아닌 경우 조회
 * 
 */

-- EMPLOYEE 테이블에서 보너스가 있는 사원의 이름 보너스 조회

SELECT EMP_NAME, BONUS
FROM EMPLOYEE
WHERE BONUS IS NOT NULL; --=> 보너스가 있는 사람들(보너스열에 컬럼값 존재하는 사람)

--------------------------------------------------------------

/*
 * ORDER BY 절
 * 
 * - SELECT문의 조회 결과(RESULT SET)을 정렬할 때 사용하는 구문
 * 
 * ** SELECT문 해석 시 가장 마지막에 해석된다! **
 */


-- EMPLOYEE 테이블에서 / 급여 오름차순으로 / 사번, 이름, 급여 조회
--		(FROM절)		(ORDER BY절)			(SELECT절)

SELECT EMP_ID, EMP_NAME, SALARY
FROM EMPLOYEE
ORDER BY SALARY ASC;
-- ASC : 오름차순 (기본값, thus 안적어도 ok)
-- DESC : 내림차순

-- EMPLOYEE 테이블에서 / 급여가 2백 만원 이상인 사원의 / 사번, 이름, 급여 조회. /단, 급여 내림차순
--		(FROM절)				(WHERE절)			(SELECT절)		(ORDER BY절)

SELECT EMP_ID, EMP_NAME, SALARY
FROM EMPLOYEE
WHERE SALARY >= 2000000
ORDER BY 3 DESC; -- 조회된 RESULT SET의 3번 째 컬럼을 의미
				-- => 3번 째 컬럼인 SALARY를 내림차순으로!

-- 입사일 순서대로 이름, 입사일 조회 (별칭 사용)
SELECT EMP_NAME 이름, HIRE_DATE 입사일
FROM EMPLOYEE
ORDER BY 입사일;
-- 해석 순서 상 SELECT절(3rd)이 먼저 수행되므로 그 별칭이 ORDER BY절(4th)에서 적용 가능!
-- => 별칭 사용은 SELECT절 이후에 가능! bcuz SELECT절 해석 순서가 FROM절, WHERE절 이후

-- 정렬 중첩 : 대분류 정렬 후 소분류 정렬
-- 부서코드 오름차순 정렬 후 급여 내림차순 정렬
--			(대분류)		(소분류)
SELECT EMP_NAME, DEPT_CODE, SALARY
FROM EMPLOYEE
ORDER BY DEPT_CODE ASC, SALARY DESC;










