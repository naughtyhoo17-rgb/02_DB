-- 함수 : 컬럼의 값을 읽어서 연산을 한 결과를 반환

-- 단일행 함수 : N개의 값을 읽어 연산 후 N개의 결과를 반환
-- 그룹 함수 : N개의 값을 읽어 연산 후 1개의 결과를 반환(합계, 평균, 최대/최소)

-- 함수는 SELECT문의
-- SELECT절, WHERE절, ORDER BY절, GROUP BY절, HAVING절에서 사용 가능

----------------------- 단일행 함수 -----------------------

-- LENGTH(컬럼명 | 문자열) : 길이 반환
-- 모든 사원의 EMAIL, EMAIL 길이를 조회
SELECT EMAIL, LENGTH(EMAIL) FROM EMPLOYEE;

---------------------------------------------------------------


-- INSTR(컬럼명 | 문자열, '찾을 문자열' [, 찾기 시작할 위치] [, 순번])
-- 지정한 위치부터 지정한 순 번째로 검색되는 문자의 위치를 반환 => 숫자 형태로 반환

-- 문자열을 앞에서부터 검색하여 첫 번째 B의 위치 조회
-- AABAACAABBAA

SELECT INSTR('AABAACAABBAA', 'B') FROM DUAL; -- 3

-- 문자열을 5번 째 문자부터 검색하여 처음 나오는 B 위치 조회
SELECT INSTR ('AABAACAABBAA', 'B', 5) FROM DUAL; -- 9

-- 문자열을 5번 째 문자부터 검색하여 두 번째로 나오는 B 위치 조회
SELECT INSTR('AABAACAABBAA', 'B', 5, 2) FROM DUAL; -- 10

-- EMPLOYEE 테이블에서 사원명, 이메일, 이메일 중 '@' 위치 조회
SELECT EMP_NAME, EMAIL, INSTR(EMAIL, '@') FROM EMPLOYEE;

---------------------------------------------------------------

-- SUBSTR(컬럼명 | 문자열, 잘라내기 시작할 위치 [, 잘라낼 길이])
-- 컬럼이나 문자열에서 지정한 위치부터 지정된 길이만큼 문자열을 잘라내어 반환
-- 잘라낼 길이 생략 시, 끝까지 잘라냄

-- EPLOYEE 테이블에서 사원명, 이메일 중 아이디만 조회
SELECT EMP_NAME, SUBSTR(EMAIL, 1, INSTR(EMAIL,'@') - 1) "ID" FROM EMPLOYEE;

---------------------------------------------------------------

-- TRIM([[옵션]문자열 | 컬럼명 FROM] 컬럼명 | 문자열)
-- 주어진 컬럼이나 문자열의 앞, 뒤, 또는 양 쪽에 있는 지정된 문자를 제거
-- => 양 쪽 공백 제거 용도로 많이 사용

-- [옵션] : LEADING(앞쪽), TRAILING(뒷쪽), BOTH(양쪽, 기본값)
SELECT TRIM('      H E L L O      ') FROM DUAL; -- 'H E L L O'

-- '####안녕####'
SELECT TRIM(BOTH '#' FROM '####안녕####') FROM DUAL; -- '안녕'
SELECT TRIM(LEADING '#' FROM '####안녕####') FROM DUAL; -- '안녕####'
SELECT TRIM(TRAILING '#' FROM '####안녕####') FROM DUAL; -- '####안녕'

---------------------------------------------------------------

-- ABS(숫자 | 컬럼명) : 절댓값
SELECT ABS(-10) FROM DUAL; -- 10

SELECT '절대값 같음' FROM DUAL WHERE ABS(10) = ABS(-10); -- WHERE절에서도 가능

-- MOD(숫자 | 컬럼명, 숫자 | 컬럼명) : 나머지 값 반환
-- EMPLOYEE 테이블에서 사원의 월급을 1백 만으로 나눴을 때 나머지 값 조회
SELECT EMP_NAME, SALARY, MOD(SALARY,1000000) FROM EMPLOYEE;

-- EMPLOYEE 테이블에서 사번이 짝수인 사원의 사번, 이름 조회
SELECT EMP_ID, EMP_NAME FROM EMPLOYEE WHERE MOD(EMP_ID, 2) = 0;

-- ROUND(숫자 | 컬럼명 [, 표시할 소숫점 위치]) : 반올림
-- 소숫점 위치 미작성 시 소숫점 첫 번째 자리에서 반올림
SELECT ROUND(123.456) FROM DUAL; -- 123
SELECT ROUND(123.456, 1) FROM DUAL; -- 123.5 <= 소숫점 두 번째 자리에서 반올림

-- CEIL(숫자 | 컬럼명) : 올림
-- FLOOR(숫자 | 컬럼명) : 내림
-- => 둘 다 소숫점 첫 번째 자리에서 올림/내림 처리
SELECT CEIL(123.1), FLOOR(123.9) FROM DUAL;

-- TRUNC(숫자 | 컬럼명, [위치]) : 특정 위치 아래를 절삭
SELECT TRUNC(123.456) FROM DUAL; -- 소숫점 아래 모두 절삭
SELECT TRUNC(123.456, 1) FROM DUAL; -- 123.4 => 1 번째 자리 아래를 모두 절삭







