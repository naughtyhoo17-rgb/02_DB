-- TCL (Transaction Control Language) : 트랜잭션 제어 언어
-- COMMIT, ROLLBACK, SAVEPOINT

-- DML : 데이터 조작언어로 데이터의 삽입/삭제/수정
-- => 트랜잭션은 DML과 관련되어 있음..

/* TRANSACTION 이란?
 * - 데이터베이스의 논리적 연산 단위
 * - 데이터 변경 사항을 묶어서 하나의 트랜잭션에 담아 처리함.
 * - 트랜잭션의 대상이 되는 데이터 변경 사항 : INSERT, UPDATE, DELETE, MERGE
 *
 * INSERT 수행 ------------------------------------------> DB 반영 (X)
 *
 * INSERT 수행 -----> 트랜잭션에 추가 ---> COMMIT ------------> DB 반영 (O)
 *
 * INSERT 10번 수행 --> 1개 트랜잭션에 10개 추가 --> ROLLBACK --> DB 반영 (X)
 *
 *
 * 1) COMMIT : 메모리 버퍼(트랜잭션)에 임시 저장된 데이터 변경 사항을 DB에 반영
 *
 * 2) ROLLBACK : 메모리 버퍼(트랜잭션)에 임시 저장된 데이터 변경 사항을 삭제하고
 *                마지막 COMMIT 상태로 돌아감 (DB에 변경 내용 반영 X)
 *
 * 3) SAVEPOINT : 메모리 버퍼(트랜잭션)에 저장 지점을 정의하여
 *                ROLLBACK 수행 시 전체 작업을 삭제하는 것이 아닌
 *                저장 지점까지만 일부 ROLLBACK
 *
 * 
 * [SAVEPOINT 사용법]
 *
 * ... (DML 수행되는 과정)
 * SAVEPOINT "포인트명1";
 *
 * ...
 * SAVEPOINT "포인트명2";
 *
 * ...
 * ROLLBACK TO "포인트명1"; -- 포인트1 지점까지 데이터 변경사항 삭제
 * 							(포인트명1 이후에 내용 삭제되는 것)
 *
 *
 * ** SAVEPOINT 지정 및 호출 시 이름에 ""(쌍따옴표) 붙여야함 !!! ***
 *
 * */

-- 새로운 데이터 INSERT

SELECT * FROM DEPARTMENT2;

INSERT INTO DEPARTMENT2 VALUES ('T1', '개발1팀', 'L2');
INSERT INTO DEPARTMENT2 VALUES ('T2', '개발2팀', 'L2');
INSERT INTO DEPARTMENT2 VALUES ('T3', '개발3팀', 'L2');

-- INSERT 확인
SELECT * FROM DEPARTMENT2;
-- => DB에 반영된 것처럼 보이지만 실제로 아직 반영되지 않음
-- 트랙잭션에 INSERT 내역 3개 들어가 있는 것.

ROLLBACK; -- 마지막 커밋시점까지 되돌아감
SELECT * FROM DEPARTMENT2; -- INSERT 내용 모두 사라짐

-- INSERT 후 COMMIT
INSERT INTO DEPARTMENT2 VALUES ('T1', '개발1팀', 'L2');
INSERT INTO DEPARTMENT2 VALUES ('T2', '개발2팀', 'L2');
INSERT INTO DEPARTMENT2 VALUES ('T3', '개발3팀', 'L2');

SELECT * FROM DEPARTMENT2;

COMMIT; -- DB에 영구 반영

ROLLBACK; -- 소용 없음 이미 late

SELECT * FROM DEPARTMENT2;
-- INSERT한 T1~T3 그대로 DB에 반영되어 있음 thru COMMIT

-----------------------------------------------------------------

-- SAVEPOINT 확인 예제

INSERT INTO DEPARTMENT2 VALUES('T4', '개발4팀', 'L2');
SAVEPOINT "SP1"; -- SAVEPOINT 지정

INSERT INTO DEPARTMENT2 VALUES('T5', '개발5팀', 'L2');
SAVEPOINT "SP2"; -- SAVEPOINT 지정

INSERT INTO DEPARTMENT2 VALUES('T6', '개발6팀', 'L2');
SAVEPOINT "SP3"; -- SAVEPOINT 지정

ROLLBACK TO "SP1";

SELECT * FROM DEPARTMENT2; -- SP1 이전에 INSERT한 개발4팀만 남음
-- cf) SP1 이후에 INSERT한 내용 뿐 아니라 SP2, SP3 SAVEPOINT 자체도 삭제됨
-- => ex) 'SP2' 저장점이 이 세션에 설정되지 않았거나 부적합합니다.

INSERT INTO DEPARTMENT2 VALUES('T5', '개발5팀', 'L2');
SAVEPOINT "SP2"; -- SAVEPOINT 지정

INSERT INTO DEPARTMENT2 VALUES('T6', '개발6팀', 'L2');
SAVEPOINT "SP3"; -- SAVEPOINT 지정

-- 개발팀 전체 삭제하기
DELETE FROM DEPARTMENT2
WHERE DEPT_ID LIKE 'T%';

SELECT * FROM DEPARTMENT2;

-- SP2 지점까지 롤백
ROLLBACK TO "SP2";
SELECT * FROM DEPARTMENT2; -- 개발5팀까지 되살아남(개발6팀만 제외)

-- SP1 지점까지 롤백
ROLLBACK TO "SP1";
SELECT * FROM DEPARTMENT2; -- 개발5팀까지 없어짐

-- 롤백 수행
ROLLBACK; -- T3까지 INSERT했던 마지막 COMMIT 시점으로 돌아감
SELECT * FROM DEPARTMENT2; -- 개발1~3팀만 남음










