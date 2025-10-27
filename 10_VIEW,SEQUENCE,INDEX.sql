/* VIEW
 * 
 * 	- 논리적 가상 테이블
 * 	-> 테이블 모양을 하고는 있지만, 실제로 값을 저장하고 있진 않음.
 * 
 *  - SELECT문의 실행 결과(RESULT SET)를 저장하는 '객체'
 * 
 * 
 * ** VIEW 사용 목적 **
 *  1) 복잡한 SELECT문을 쉽게 재사용하기 위해.
 *  2) 테이블의 진짜 모습을 감출 수 있어 보안상 유리.
 * 
 * 
 * ** VIEW 사용 시 주의 사항 **
 * 	1) 가상의 테이블(실체 X)이기 때문에 ALTER 구문 사용 불가.
 * 	2) VIEW를 이용한 DML(INSERT,UPDATE,DELETE)이 가능한 경우도 있지만
 *     제약이 많이 따르기 때문에 조회(SELECT) 용도로 대부분 사용.
 * 
 * 
 *  ** VIEW 작성법 **
 *  CREATE [OR REPLACE] [FORCE | NOFORCE] VIEW 뷰이름 [컬럼 별칭]
 *  AS 서브쿼리(SELECT문)
 *  [WITH CHECK OPTION]
 *  [WITH READ OLNY];
 * 
 *  1) OR REPLACE 옵션 : 
 *	  기존에 동일한 이름의 VIEW가 존재하면 이를 변경, 없으면 새로 생성
 * 
 *  2) FORCE | NOFORCE 옵션 : 
 *    FORCE : 서브쿼리에 사용된 테이블이 존재하지 않아도 뷰 생성
 *    NOFORCE(기본값): 서브쿼리에 사용된 테이블이 존재해야만 뷰 생성
 *    
 *  3) 컬럼 별칭 옵션 : 조회되는 VIEW의 컬럼명을 지정
 * 
 *  4) WITH CHECK OPTION 옵션 : 
 * 	  옵션을 지정한 컬럼의 값을 수정 불가능하게 함.
 * 
 *  5) WITH READ OLNY 옵션 :
 * 	  뷰에 대해 SELECT만 가능하도록 지정. (읽기 전용)
 * 
 * */

-- VIEW 생성 위해서는 권한이 필요!!

-- (SYS 계정 접속)

-- VIEW 생성 권한 부여 (SYS -> kh_psm)
GRANT CREATE VIEW TO kh_psm;

-- VIEW 생성
CREATE VIEW V_EMP AS SELECT * FROM EMPLOYEE;
-- ORA-01031: 권한이 불충분합니다
CREATE VIEW V_EMP AS SELECT * FROM EMPLOYEE;
-- sys에서 권한 부여 후, kh_psm에서 재수행 => 생성 ok

SELECT * FROM V_EMP; -- VIEW 생성 확인

-- 사번, 이름, 부서명, 직급명 조회하기 위한 VIEW 생성
CREATE OR REPLACE VIEW V_EMP AS 
SELECT EMP_ID 사번, EMP_NAME 이름,
NVL(DEPT_TITLE, '없음') 부서명, JOB_NAME 직급명
FROM EMPLOYEE JOIN JOB USING(JOB_CODE)
LEFT JOIN DEPARTMENT ON (DEPT_CODE  = DEPT_ID)
ORDER BY 사번;

SELECT * FROM V_EMP;

-- 직급명이 대리인 사원 조회(JOB_NAME 아니고 '직급명'을 그대로)
SELECT * FROM V_EMP
WHERE 직급명 = '대리'
ORDER BY 이름;
-- => VIEW 조회 결과로 보여지는 컬럼명을 그대로 이용!

-----------------------------------------------------------------

-- VIEW 이용해 DML 사용하기 + 문제점 확인

-- DEPARTMENT 테이블 복사한 DEPT_COPY2 생성(테이블로 생성)
CREATE TABLE DEPT_COPY2 AS SELECT * FROM DEPARTMENT;

-- DEPT_COPY2 테이블에서 DEPT_ID, LOCATION_ID 컬럼만 이용해 V_DCOPY2 VIEW 생성
CREATE OR REPLACE VIEW V_DCOPY2
AS SELECT DEPT_ID, LOCATION_ID FROM DEPT_COPY2;

-- V_DCOPY2 VIEW 생성 확인
SELECT * FROM V_DCOPY2; 

-- 원본 테이블
SELECT * FROM DEPT_COPY2;

-- V_DCOPY2 VIEW에 INSERT 수행 (권장하지 않지만 VIEW에 DML 가능)
INSERT INTO V_DCOPY2 VALUES ('D0', 'L2');
-- => 가상테이블인 VIEW에도 INSERT 오류없이 성공 

SELECT * FROM DEPT_COPY2; -- VIEW에 INSERT 했음에도 원본 '테이블'도 변경(INSERT)됨
-- btw, VIEW에는 DEPT_TITLE이 없어서 테이블에 NULL값으로 INSERT 됨
-- => VIEW 생성에 사용된 컬럼에만 데이터값이 삽입
-- thus NULL은 '값이 없다'는 뜻으로 DB의 무결성 훼손되므로 의도치 않은 NULL을 지양해야!

-- * 무결성 : DB에서 데이터를 정확하고 일관되게 유지하기 위한 중요한 개념 *
-- 데이터의 정확성, 일관성, 신뢰성 보장

-- WITH READ ONLY(읽기 전용) 옵션 사용하기
-- VIEW 이용한 DML(삽입/갱신/삭제) 막기 위해 사용.

CREATE OR REPLACE VIEW V_DCOPY2
AS SELECT DEPT_ID, LOCATION_ID FROM DEPT_COPY2
WITH READ ONLY;

INSERT INTO V_DCOPY2 VALUES ('D0', 'L2');
-- ORA-42399: 읽기 전용 뷰에서는 DML 작업을 수행할 수 없습니다.

SELECT * FROM V_DCOPY2;

------------------------------------------------------------------
------------------------------------------------------------------

/* 
 * SEQUENCE(순서, 연속)
 * - 순차적으로 일정한 간격의 숫자(번호)를 발생시키는 객체 (번호 생성기)
 * 
 * *** SEQUENCE 왜 사용할까?? ***
 * PRIMARY KEY(기본키) : 테이블 내 각 행을 구별하는 식별자 역할
 * 					  NOT NULL + UNIQUE의 의미를 가짐
 * 
 * PK가 지정된 컬럼에 삽입될 값을 생성할 때 SEQUENCE를 이용하면 좋다!
 * 
 *   [작성법]
  CREATE SEQUENCE 시퀀스이름
  [STRAT WITH 숫자] -- 처음 발생시킬 시작값 지정, 생략하면 1이 기본
  [INCREMENT BY 숫자] -- 다음 값에 대한 증가치, 생략하면 1이 기본
  [MAXVALUE 숫자 | NOMAXVALUE] -- 발생시킬 최대값 지정, 생략하면 기본값은 10^27 - 1 (즉, 매우 큰 값)
  							/ NOMAXVALUE를 사용하면 최대값 제한이 없음을 의미
  [MINVALUE 숫자 | NOMINVALUE] -- 최소값 지정 , 기본값은 -10^26
  							/ NOMINVALUE를 사용하면 최소값 제한이 없음을 의미
  [CYCLE | NOCYCLE] -- 값 순환 여부 지정 , 기본값은 NOCYCLE
		-- CYCLE: 값이 최대값에 도달하면 다시 최소값부터 순환
		-- NOCYCLE: 값을 순환하지 않고, 최대값에 도달하면 오류를 발생시킴
  [CACHE 시퀀스개수 | NOCACHE] -- 기본값은 20
	-- 시퀀스의 캐시 메모리는 할당된 크기만큼 미리 다음 값들을 생성해 저장해둠
	--> 시퀀스 호출 시 미리 저장되어진 값들을 가져와 반환하므로 
	--  매번 시퀀스를 생성해서 반환하는 것보다 DB속도가 향상됨.
 * 
 * 
 * ** 사용법 **
 * 
 * 1) 시퀀스명.NEXTVAL : 다음 시퀀스 번호를 얻어옴. (INCREMENT BY 만큼 증가된 수)
 * 					  단, 생성 후 처음 호출된 시퀀스인 경우
 * 					  START WITH에 작성된 값이 반환됨.
 * 
 * 2) 시퀀스명.CURRVAL : 현재 시퀀스 번호를 얻어옴.
 * 					  단, 시퀀스가 생성 되자마자 호출할 경우 오류 발생.
 * 				      == 마지막으로 호출한 NEXTVAL 값을 반환
 * */

-- 시퀀스 생성하기
CREATE SEQUENCE SEQ_TEST_NO
START WITH 100 -- 100 번부터 시작
INCREMENT BY 5 -- 5 씩 증가 => NEXTVAL 호출 시 5 씩 증가한 값 조회됨
MAXVALUE 150   -- 증가 가능한 최댓값 150
NOMINVALUE 	   -- 최솟값 없음
NOCYCLE		   -- 반복 순환 안함
NOCACHE;	   -- 미리 만들어 둘 시퀀스 번호 없음

-- 시퀀스 테스트용 테이블 생송
CREATE TABLE TB_TEST(
	TEST_NO NUMBER PRIMARY KEY,
	TEST_NAME VARCHAR2(30) NOT NULL
);

SELECT * FROM TB_TEST;

-- 현재 시퀀스 번호 확인
SELECT SEQ_TEST_NO.CURRVAL FROM DUAL;
-- ORA-08002: 시퀀스 SEQ_TEST_NO.CURRVAL은 이 세션에서는 정의 되어 있지 않습니다
-- CURRVAL의 정확한 의미는 가장 마지막에 호출된 NEXTVAL값을 반환하는 것
-- btw, 아직 한번도 NEXTVAL 호출한 적이 없어 오류 발생

-- -> 해결 방법 => NEXTVAL 호출
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL; -- 100 
-- 시퀀스 생성 후 첫 NEXTVAL == START WITH에 지정한 값 == 100
SELECT SEQ_TEST_NO.CURRVAL FROM DUAL; -- 100

-- NEXTVAL 호출할 때 마다 INCREMENT BY에 작성한 수만큼 증가 확인
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL; -- 105
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL; -- 110
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL; -- 115
SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL; -- 120

-- TB_TEST 테이블에 PK로 지정된 컬럼값에 SEQ_TEST_NO 시퀀스로 생성한 값 삽입
INSERT INTO TB_TEST VALUES(SEQ_TEST_NO.NEXTVAL, '짱구'); -- 125 짱구
INSERT INTO TB_TEST VALUES(SEQ_TEST_NO.NEXTVAL, '철수'); -- 130 철수
INSERT INTO TB_TEST VALUES(SEQ_TEST_NO.NEXTVAL, '유리'); -- 135 유리

SELECT * FROM TB_TEST; 

-----------------------------------------------------------------

-- UPDATE에서 시퀀스 사용
-- '짱구'의 PK 컬럼값을 SEQ_TEST_NO 시퀀스의 다음 생성값으로 변경

UPDATE TB_TEST SET TEST_NO = SEQ_TEST_NO.NEXTVAL
WHERE TEST_NAME = '짱구';
-- ORA-08004: 시퀀스 SEQ_TEST_NO.NEXTVAL exceeds MAXVALUE은
-- 사례로 될 수 없습니다
-- 짱구의 TEST_NO값을 150까지 증가시키고 나서 또 한번 NEXTVAL 호출한 결과
-- => MAXVALUE 150보다 증가할 수 없다!

SELECT * FROM TB_TEST;

-----------------------------------------------------------------

-- SEQUENCE 변경 (ALTER)
-- => START WITH(시작값) 빼고 모두 변경 가능

-- [작성법]
/*
 * ALTER SEQUENCE 시퀀스이름
 * [INCREMENT BY 숫자]
 * [MAXVALUE 숫자 | NOMAXVALUE]
 * [MINVALUE 숫자 | NOMINVALUE]
 * [CYCLE | NOCYCLE]
 * [CACHE byte크기 | NOCACHE]
 * 
 */

-- SEQ_TEST_NO의 MAXVALUE값 200으로 수정
ALTER SEQUENCE SEQ_TEST_NO MAXVALUE 200;

SELECT SEQ_TEST_NO.NEXTVAL FROM DUAL;

------------------------------------------------------------------

-- VIEW, SEQUENCE 삭제
DROP VIEW V_DCOPY2;
DROP SEQUENCE SEQ_TEST_NO;

------------------------------------------------------------------
------------------------------------------------------------------

/* 
 * INDEX(색인)
 * - SQL 구문 중 SELECT 처리 속도를 향상 시키기 위해 
 *   컬럼에 대하여 생성하는 객체
 * 
 * - 인덱스 내부 구조는 B* 트리(B-star tree) 형식으로 되어있음.
 * 
 * 
 * ** INDEX의 장점 **
 * - 이진 트리 형식으로 구성되어 자동 정렬 및 검색 속도 증가.
 * 
 * - 조회 시 테이블의 전체 내용을 확인하며 조회하는 것이 아닌
 *   인덱스가 지정된 컬럼만을 이용해서 조회하기 때문에 시스템의 부하가 낮아짐.
 * 
 * 
 * ** INDEX의 단점 **
 * - 데이터 변경(INSERT,UPDATE,DELETE) 작업 시 
 * 	 이진 트리 구조에 변형이 일어남
 * 	  => DML 작업이 빈번한 경우 시스템 부하가 늘어 성능이 저하됨.
 * 
 * - 인덱스도 하나의 객체이다 보니 별도 저장공간이 필요(메모리 소비)
 * 
 * - 인덱스 생성 시간이 필요함.
 * 
 * 
 *  [작성법]
 *  CREATE [UNIQUE] INDEX 인덱스명
 *  ON 테이블명 (컬럼명[, 컬럼명 | 함수명]);
 * 
 *  DROP INDEX 인덱스명;
 * 
 * 
 *  ** 인덱스가 자동 생성되는 경우 **

 *  -> PK 또는 UNIQUE 제약조건이 설정된 컬럼에 대해 UNIQUE INDEX가 자동 생성 

 * PK에 자동 생성되는 이유 : 기본 키는 중복을 허용하지 않고, NOT NULL이어야 하기 때문
 * UNIQUE 제약조건 설정 컬럼에서 자동 생성되는 이유 :
 * 		중복을 허용하지 않는 고유값을 보장해야하기 때문
 * 
 * */

SELECT ROWID, EMP_ID, EMP_NAME FROM EMPLOYEE;
-- ROWID : 오라클에서 각 행의 고유한 주소를 나타내는 가상 컬럼

/*
 * ROWID와 INDEX 무슨 관계?
 * 인덱스가 ROWID를 저장함.
 * 컬럼값과 해당 행의 ROWID를 MAPPING해서 저장함.
 * 즉, 인덱스의 핵심 역할은 컬럼값 -> 해당 행의 ROWID를 통해 빠르게 찾아내는 것
 *
 */

-- 현재 사용자에 생성된 인덱스 목록 조회
SELECT INDEX_NAME, TABLE_NAME, UNIQUENESS, STATUS FROM USER_INDEXES;
/*
 * INDEX_NAME : 인덱스 이름
 * TABLE_NAME : 인덱스가 적용된 테이블명
 * UNIQUENESS : UNIQUE 여부 (UNIQUE/NONUNIQUE)
 * STATUS : VALID(정상)/UNUSABLE(비활성화)
 */

-- 인덱스 성능 확인용 테이블 생성
CREATE TABLE TB_IDX_TEST(
	TEST_NO NUMBER PRIMARY KEY, -- 자동으로 UNIQUE INDEX 생성됨
	TEST_ID VARCHAR2(20) NOT NULL
);

-- TB_IDX_TEST 테이블에 샘플 데이터 100만 개 삽입 (PL/SQL 사용)
-- 조건문(IF/CASE), 반복문(LOOP/WHILE), 변수 선언 등... 가능

BEGIN
	FOR I IN 1..1000000 -- I를 1부터 1백 만까지 반복
	LOOP
		INSERT INTO TB_IDX_TEST VALUES(I, 'TEST' || I);
	END LOOP;
	COMMIT; -- 모든 삽입 커밋
END;

SELECT COUNT(*) FROM TB_IDX_TEST; -- 100만 개의 행 삽입 확인

-- 인덱스 사용해 검색하는 방법
-- => WHERE절에 INDEX가 지정된 컬럼 언급

-- 인덱스 사용 x
-- TEST_ID 'TEST500000'행 조회
SELECT * FROM TB_IDX_TEST
WHERE TEST_ID = 'TEST500000';

-- 인덱스 사용 o
-- TEST_NO가 500000인 행 조회
SELECT * FROM TB_IDX_TEST
WHERE TEST_NO = 500000;
-- => 보통 10~30배 정도 인덱스 사용한 조회가 빠름












