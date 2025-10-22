-- cf) 윈도우 -> 설정 -> 연결 -> 연결유형
-- Auto commit by default 체크 해제!

-- <주의> 혼자서 COMMIT, ROLLBACK 금지!

---------------------------------------------------------

-- ** DML (Data Manipulation Language) : 데이터 조작 언어 **

-- 테이블에 값을 삽입(INSERT), 수정(UPDATE), 삭제(DELETE) 하는 구문

-- 테스트용 테이블 생성
CREATE TABLE EMPLOYEE2 AS SELECT * FROM EMPLOYEE;
CREATE TABLE DEPARTMENT2 AS SELECT * FROM DEPARTMENT;

SELECT * FROM EMPLOYEE2;
SELECT * FROM DEPARTMENT2;

-----------------------------------------------------------

-- 1. INSERT
-- 테이블에 새로운 행을 추가하는 구문

-- 1) INSERT INTO 테이블명 VALUES(데이터, 데이터, 데이터...);
-- 테이블에 있는 모든 컬럼의 대한 값을 INSERT할 때 사용 (컬럼 순으로 데이터 입력)
SELECT * FROM EMPLOYEE2;

INSERT INTO EMPLOYEE2 VALUES('900', '홍길동', '991215-1234567',
'hong_gd@or.kr', '01011111111', 'D1', 'J7', 'S3', 4300000, 0.2,
200, SYSDATE, NULL, 'N');

SELECT * FROM EMPLOYEE2 WHERE EMP_ID = '900';
ROLLBACK; -- 마지막 COMMIT 시점까지 되돌아감 
		  -- INSERT 내용 뒤집어 엎는다 => 홍길동 없어짐

-- 2) INSERT INTO 테이블명 (컬럼명1, 컬럼명2, 컬럼명3...)
--		VALUES(데이터1, 데이터2, 데이터3...);
-- 테이블에 내가 선택한 컬럼에 대한 값만 INSERT할 때 사용
-- 선택하지 않은 컬럼의 값은 NULL로 입력됨
-- (DEFAULT 존재 시 DEFAULT 설정값으로 삽입됨)

INSERT INTO EMPLOYEE2 (EMP_ID, EMP_NAME, EMP_NO,
EMAIL, PHONE, DEPT_CODE, JOB_CODE, SAL_LEVEL, SALARY)
VALUES('900', '홍길동', '991215-1234567',
'hong_gd@or.kr', '01011111111', 'D1', 'J7', 'S3', 4300000)

SELECT * FROM EMPLOYEE2 WHERE EMP_ID = '900';
-- cf) DEFAULT는 복사한 테이블에 따라가지 않음 thus EMPLOYEE2에는 DEFAULT 없음

COMMIT; -- 트랜잭션에만 존재하던 '홍길동' 데이터 영구 저장!

ROLLBACK; -- 트랜잭션 바구니에 엎어질 내용이 없음
SELECT * FROM EMPLOYEE2 WHERE EMP_ID = '900'; -- DB에 영구저장 되어 사라지지 않음
-- => 이미 영구저장 되었기에 되돌리기 불가능

-- INSERT 시 VALUES 대신 SUB-QUERY 사용 가능
CREATE TABLE EMP_01(
	EMP_ID NUMBER,
	EMP_NAME VARCHAR2(30),
	DEPT_TITLE VARCHAR2(20)
); -- 테이블 생성하는 기본 문법 예시

SELECT * FROM EMP_01; -- INSERT 거치지 않아 컬럼값은 다 비어있음

SELECT EMP_ID, EMP_NAME, DEPT_TITLE
FROM EMPLOYEE2 
LEFT JOIN DEPARTMENT2 ON (DEPT_CODE = DEPT_ID);

-- 서브쿼리(SELECT) 결과(RESULT SET)를 EMP_01 테이블에 INSERT
-- => 조회 결과의 데이터 타입, 컬럼 갯수가 INSERT 하려는 테이블의 컬럼과 일치해야 함.

INSERT INTO EMP_01(
	SELECT EMP_ID, EMP_NAME, DEPT_TITLE
	FROM EMPLOYEE2 
	LEFT JOIN DEPARTMENT2 ON (DEPT_CODE = DEPT_ID) -- 위에 SELECT문 그대로
); 

SELECT * FROM EMP_01;

-----------------------------------------------------------------
-----------------------------------------------------------------

-- 2. UPDATE (내용을 바꾸거나 추가해서 최신화)
-- 테이블에 기록된 컬럼값을 수정하는 구문

-- [작성법]
/*
 * UPDATE 테이블명
 * SET 컬럼명 = 바꿀 값
 * [WHERE 컬럼명 비교연산자 비교값] => WHERE절은 옵션이지만 절의 조건 중요!
 * 
 */

-- DEPARTMENT2 테이블에서 DEPT_ID가 'D9'인 부서 정보 조회
SELECT * FROM DEPARTMENT2
WHERE DEPT_ID = 'D9';

-- DEPARTMENT2 테이블에서 DEPT_ID가 'D9'인 부서의
-- DEPT_TITLE을 '전략기획팀'으로 수정
UPDATE DEPARTMENT2 SET DEPT_TITLE = '전략기획팀'
WHERE DEPT_ID = 'D9';

-- * 조건절 설정없이 UPDATE 구문 실행 시 모든 행의 컬럼값이 변경됨 *

SELECT * FROM DEPARTMENT2;

UPDATE DEPARTMENT2 SET DEPT_TITLE = '기술연구팀';

-- EMPLOYEE2 테이블에서 BONUS를 받지 않는 사원의 BONUS를 0.1로 수정
UPDATE EMPLOYEE2 SET BONUS = '0.1'
WHERE BONUS IS NULL;

SELECT * FROM EMPLOYEE2;

ROLLBACK;

------------------------------------------------------------------

-- 여러 컬럼을 한번에 수정 시 ,콤마로 구분하여 컬럼 나열
-- D9 / 총부무 -> D0 / 전략기획팀 수정

UPDATE DEPARTMENT2 SET DEPT_ID = 'D0',
DEPT_TITLE = '전략기획팀'
WHERE DEPT_ID = 'D9' AND DEPT_TITLE = '총무부';

SELECT * FROM DEPARTMENT2;

-----------------------------------------------------------------

-- * UPDATE 시에도 SUB-QUERY 사용 가능

-- [작성법]
/* 
 * UPDATE 테이블명 SET
 * 컬럼명 = (서브쿼리)
 * 
 */

-- EMPLOYEE2 테이블에서 방명수 사원의 급여와 보너스율을
-- 유재식 사원의 그것과 동일하게 변경

	-- 유재식 급여 조회
	SELECT SALARY FROM EMPLOYEE2
	WHERE EMP_NAME = '유재식'; -- 3,400,000
	
	-- 유재식 보너스 조회
	SELECT BONUS FROM EMPLOYEE2
	WHERE EMP_NAME = '유재식'; -- 0.2
	
-- 방명수의 급여 보너스 수정
UPDATE EMPLOYEE2 SET
SALARY = (SELECT SALARY FROM EMPLOYEE2
WHERE EMP_NAME = '유재식'),
BONUS = (SELECT BONUS FROM EMPLOYEE2
WHERE EMP_NAME = '유재식')
WHERE EMP_NAME = '방명수';

SELECT EMP_NAME, SALARY, BONUS
FROM EMPLOYEE2
WHERE EMP_NAME IN ('유재식', '방명수');

----------------------------------------------------------------
----------------------------------------------------------------

-- 3. MERGE (병합)
-- 구조가 같은 두 개의 테이블을 하나로 합치는 기능
-- 테이블에서 지정하는 조건의 값이 존재하면 UPDATE, 없으면 INSERT

CREATE TABLE EMP_M01 AS SELECT * FROM EMPLOYEE;

CREATE TABLE EMP_M02 AS SELECT * FROM EMPLOYEE
WHERE JOB_CODE = 'J4';

SELECT * FROM EMP_M01;
SELECT * FROM EMP_M02;

INSERT INTO EMP_M02
VALUES (999, '곽두원', '561016-1234567', 'kwak_dw@or.kr',
'01011112222', 'D9', 'J4', 'S1', 9000000, 0.5, NULL,
SYSDATE, NULL, NULL);

SELECT * FROM EMP_M01; -- 23명
SELECT * FROM EMP_M02; -- 5명 (기존 4 + 신규 1)

UPDATE EMP_M02 SET SALARY = 0;

MERGE INTO EMP_M01 USING EMP_M02 ON(EMP_M01.EMP_ID = EMP_M02.EMP_ID)
WHEN MATCHED THEN
UPDATE SET
	EMP_M01.EMP_NAME = EMP_M02.EMP_NAME,
	EMP_M01.EMP_NO = EMP_M02.EMP_NO,
	EMP_M01.EMAIL = EMP_M02.EMAIL,
	EMP_M01.PHONE = EMP_M02.PHONE,
	EMP_M01.DEPT_CODE = EMP_M02.DEPT_CODE,
	EMP_M01.JOB_CODE = EMP_M02.JOB_CODE,
	EMP_M01.SAL_LEVEL = EMP_M02.SAL_LEVEL,
	EMP_M01.SALARY = EMP_M02.SALARY,
	EMP_M01.BONUS = EMP_M02.BONUS,
	EMP_M01.MANAGER_ID = EMP_M02.MANAGER_ID,
	EMP_M01.HIRE_DATE = EMP_M02.HIRE_DATE,
	EMP_M01.ENT_DATE = EMP_M02.ENT_DATE,
	EMP_M01.ENT_YN = EMP_M02.ENT_YN
WHEN NOT MATCHED THEN
INSERT VALUES(EMP_M02.EMP_ID, EMP_M02.EMP_NAME, EMP_M02.EMP_NO,
			 EMP_M02.EMAIL, EMP_M02.PHONE, EMP_M02.DEPT_CODE,
			 EMP_M02.JOB_CODE, EMP_M02.SAL_LEVEL, EMP_M02.SALARY,
			 EMP_M02.BONUS, EMP_M02.MANAGER_ID, EMP_M02.HIRE_DATE, 
	         EMP_M02.ENT_DATE, EMP_M02.ENT_YN);

SELECT * FROM EMP_M01; -- 없었던 곽두원은 INSERT, 있는데 수정이면 UPDATE

------------------------------------------------------------------
------------------------------------------------------------------

-- 4. DELETE
-- 테이블의 행을 삭제하는 구문

-- [작성법]
/*
 * DELETE FROM 테이블명 [WHERE 조건설정];
 * 만약 WHERE절 조건 미설정 시 모든 행이 다 삭제됨!
 * 
 */

COMMIT;

SELECT * FROM EMPLOYEE2
WHERE EMP_NAME = '홍길동';

-- 홍길동 삭제하기
DELETE FROM EMPLOYEE2
WHERE EMP_NAME = '홍길동';

ROLLBACK; -- 홍길동 삭제를 돌이킴 => 홍길동 부활

SELECT * FROM EMPLOYEE2
WHERE EMP_NAME = '홍길동'; => 조회 결과 있음

-- EMPLOYEE2 테이블의 행 전체 삭제
DELETE FROM EMPLOYEE2; 

SELECT * FROM EMPLOYEE2; -- 다 삭제됨

ROLLBACK;
SELECT * FROM EMPLOYEE2; -- 다 되돌아옴

-----------------------------------------------------------------
-----------------------------------------------------------------

-- 5. TRUNCATE (DML 아닌 DDL)
-- 테이블의 전체 행을 삭제하는 DDL 구문
-- DELETE보다 수행속도가 빠름
-- DML 아닌 DDL 이므로 트랜잭션에 담기지 않아 ROLLBACK 불가!

-- 테스트용 테이블 생성
CREATE TABLE EMPLOYEE3 AS SELECT * FROM EMPLOYEE2;

-- EMPLOYEE3 생성 확인
SELECT * FROM EMPLOYEE3;

-- TRUNCATE로 삭제
TRUNCATE TABLE EMPLOYEE3; -- 테이블 자체가 아닌 테이블 내 행을 전체 삭제

-- 삭제 확인
SELECT * FROM EMPLOYEE3; -- 없는 테이블이란 오류 x. 테이블 자체는 유효

-- 롤백으로도 복구 불가 확인!
ROLLBACK;
SELECT * FROM EMPLOYEE3; -- 모든 행 비어있음

/* cf) DELETE : 휴지통에 버리는 개념 => 복구 가능
	   TRUNCATE : 완전 삭제(shift + del) 개념 => 복구 불가 */









