-- DDL(Data Definition Language) : 데이터 정의 언어
-- 객체를 만들고(CREATE), 바꾸고(ALTER), 삭제(DROP)하는 데이터 정의 언어

/*
 * ALTER(바꾸다, 수정하다, 변조하다)
 * 
 * -- 테이블에서 수정할 수 있는 것
 * 1) 제약 조건(추가/삭제) * 제약 조건 자체를 수정하는 구문은 별도 존재 x
 * 					  * 만약 제약 조건 일부 수정 필요 시 삭제 후 추가해야
 * 2) 컬럼(추가/수정/삭제)
 * 3) 이름 변경 (테이블/컬럼/제약 조건) 
 * 
 * */

-- 1) 제약 조건(추가/삭제)

-- [작성법]
-- i) 추가 : ALTER TABLE 테이블명 ADD [CONSTRAINT 제약 조건명] 제약 조건(지정할 컬럼명)
--		   [REFERENCES 테이블명[(컬럼명)]]; <-- FK인 경우 

-- ii) 삭제 : ALTER TABLE 테이블명 DROP CONSTRAINT 제약 조건명;

-- DEPARTMENT 테이블 복사 (컬럼명, 데이터 타입, NOT NULL만 복사 가능)
CREATE TABLE DEPT_COPY AS SELECT * FROM DEPARTMENT;

SELECT * FROM DEPT_COPY;

-- DEPT_COPY의 DEPT_TITLE 컬럼에 UNIQUE 추가
ALTER TABLE DEPT_COPY ADD CONSTRAINT DEPT_COPY_TITLE_U UNIQUE (DEPT_TITLE);

-- DEPT_COPY의 DEPT_TITLE 컬럼에 설정된 UNIQUE 삭제
ALTER TABLE DEPT_COPY DROP CONSTRAINT DEPT_COPY_TITLE_U;

-- ** DEPT_COPY의 DEPT_TITLE 컬럼에 NOT NULL 제약 조건 추가/삭제 **
ALTER TABLE DEPT_COPY ADD CONSTRAINT DEPT_COPY_TITLENN NOT NULL (DEPT_TITLE);
-- ORA-00904: : 부적합한 식별자
-- NOT NULL 제약 조건은 새로운 조건을 추가하는 것이 아닌
-- 컬럼 자체에 NULL의 허용/비허용만을 제어하는 형태

-- MODIFIY(수정하다) 구문을 사용해 NULL 제어
ALTER TABLE DEPT_COPY MODIFY DEPT_TITLE NOT NULL; -- DEPT_TITLE 컬럼에 NULL 비허용
ALTER TABLE DEPT_COPY MODIFY DEPT_TITLE NULL; -- DEPT_TITLE 컬럼에 NULL 허용


------------------------------------------------------------------

ㄴ













