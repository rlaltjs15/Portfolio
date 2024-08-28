-- 이 스크립트는 project_jjol 데이터베이스와 필요한 테이블을 생성합니다.
-- 테이블을 순서대로 등록해야 합니다.
-- 데이터베이스를 삭제하고 새로 생성하며, 이후 각 테이블을 순차적으로 생성합니다.

-- 데이터베이스 삭제 및 생성
DROP DATABASE IF EXISTS project_jjol;
CREATE DATABASE IF NOT EXISTS project_jjol;
USE project_jjol;

-- 관리자 테이블
DROP TABLE IF EXISTS admin;
CREATE TABLE IF NOT EXISTS admin(
    admin_id VARCHAR(100) PRIMARY KEY,  -- 관리자 ID
    pass VARCHAR(100) NOT NULL,         -- 비밀번호
    root INTEGER NOT NULL,              -- 권한 레벨
    reg_date TIMESTAMP DEFAULT NOW()    -- 등록 일자
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 유저 테이블
DROP TABLE IF EXISTS user;
CREATE TABLE IF NOT EXISTS user(
    user_id VARCHAR(100) PRIMARY KEY,   -- 유저 ID
    pass VARCHAR(100),                  -- 비밀번호 (소셜 로그인 사용자는 null일 수 있음)
    name VARCHAR(100) NOT NULL,         -- 이름
    email VARCHAR(100) NOT NULL UNIQUE, -- 이메일 (고유하게 설정)
    phone VARCHAR(100) NOT NULL,        -- 전화번호
    role VARCHAR(50) NOT NULL,          -- 역할 ("student" 또는 "instructor")
    point INTEGER NOT NULL,             -- 포인트
    reg_date TIMESTAMP DEFAULT NOW(),   -- 등록 일자
    provider VARCHAR(50)                -- 소셜 로그인 제공자 (google 등)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

select * from user;

UPDATE user SET role = 'admin' WHERE user_id = 'admin';
UPDATE user SET pass = '1234' WHERE user_id = 'admin';


-- 강의 테이블
DROP TABLE IF EXISTS lecture;
CREATE TABLE lecture (
    lecture_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- 강의 ID
    lecture_title VARCHAR(255) NOT NULL,                 -- 강의 제목
    lecture_short_description VARCHAR(500) NULL,         -- 강의 짧은 설명
    lecture_long_description TEXT NULL,                  -- 강의 긴 설명
    lecture_thumbnail_video VARCHAR(1000) NULL,           -- 썸네일 비디오
    lecture_thumbnail_image VARCHAR(255) NULL,           -- 썸네일 이미지
    lecture_level VARCHAR(50) NULL,                      -- 강의 레벨
    lecture_price DECIMAL(10, 2) NULL,                   -- 강의 가격
    lecture_discount DECIMAL(5, 2) NULL,                 -- 강의 할인율
    lecture_like INT DEFAULT 0,                          -- 강의 좋아요 수
    instructor_id VARCHAR(100) NOT NULL,                 -- 강사 ID
    instructor_name VARCHAR(255) NULL                    -- 강사 이름
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 챕터 테이블
DROP TABLE IF EXISTS chapter;
CREATE TABLE IF NOT EXISTS chapter (
    chapter_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- 챕터 ID
    lecture_id INT NOT NULL,                             -- 강의 ID
    chapter_title VARCHAR(255) NOT NULL,                 -- 챕터 제목
    chapter_description VARCHAR(1000) NULL,              -- 챕터 설명
    chapter_url VARCHAR(1000) NOT NULL,                   -- 챕터 URL
    chapter_order INT NOT NULL,                          -- 챕터 순서
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 비디오 테이블
DROP TABLE IF EXISTS video;
CREATE TABLE IF NOT EXISTS video (
    video_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,    -- 비디오 ID
    lecture_id INT NOT NULL,                             -- 강의 ID
    video_title VARCHAR(255) NOT NULL,                   -- 비디오 제목
    video_description VARCHAR(1000) NULL,                -- 비디오 설명
    video_url VARCHAR(255) NOT NULL,                     -- 비디오 URL
    video_duration INT NULL,                             -- 비디오 길이 (초 단위)
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,     -- 업로드 날짜
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 결제 테이블
DROP TABLE IF EXISTS payment;
CREATE TABLE IF NOT EXISTS payment(
    pay_code INT AUTO_INCREMENT PRIMARY KEY,             -- 결제 코드
    pay_date TIMESTAMP DEFAULT NOW(),                    -- 결제 날짜
    pay_way VARCHAR(100) NULL,                           -- 결제 방법
    price INTEGER NOT NULL,                              -- 가격
    lecture_title VARCHAR(255),                          -- 강의 제목
    user_id VARCHAR(100),                                -- 유저 ID
    lecture_id INT,                                      -- 강의 ID
    merchant_uid VARCHAR(255) NOT NULL,                  -- 결제 ID
    FOREIGN KEY(user_id) REFERENCES user(user_id),
    FOREIGN KEY(lecture_id) REFERENCES lecture(lecture_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강의신청 테이블
DROP TABLE IF EXISTS lectureApplication;
CREATE TABLE IF NOT EXISTS lectureApplication (
    application_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- 신청 ID
    application_date TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, -- 신청 날짜
    user_id VARCHAR(100) NOT NULL,                           -- 유저 ID
    lecture_id INT NOT NULL,                                 -- 강의 ID
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강의페이지 테이블
DROP TABLE IF EXISTS lecturePage;
CREATE TABLE IF NOT EXISTS lecturePage (
    page_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,       -- 페이지 ID
    lecture_id INT NOT NULL,                               -- 강의 ID
    user_id VARCHAR(100) NOT NULL,                         -- 유저 ID
    chapter_id INT NOT NULL,                               -- 챕터 ID
    start_time INT NULL DEFAULT 0,                         -- 시작 시간 (초 단위)
    last_viewed TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,  -- 마지막 조회 시간
    last_chapter_order INT DEFAULT 1,                      -- 마지막 챕터 순서
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (chapter_id) REFERENCES chapter(chapter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강의평가 테이블
DROP TABLE IF EXISTS lectureReview;
CREATE TABLE IF NOT EXISTS lectureReview (
    review_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,    -- 리뷰 ID
    review_content VARCHAR(1000) NULL,                    -- 리뷰 내용
    lecture_id INT NOT NULL,                              -- 강의 ID
    user_id VARCHAR(100) NOT NULL,                        -- 유저 ID
    rating DOUBLE NOT NULL,                               -- 평점
    review_date TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP, -- 리뷰 날짜
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강의노트 테이블
DROP TABLE IF EXISTS lectureNote;
CREATE TABLE IF NOT EXISTS lectureNote (
    note_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,      -- 노트 ID
    lecture_id INT NOT NULL,                              -- 강의 ID
    user_id VARCHAR(100) NOT NULL,                        -- 유저 ID
    note_content VARCHAR(1000) NULL,                      -- 노트 내용
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,  -- 생성 날짜
    note_title VARCHAR(255),                              -- 노트 제목
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강의 커뮤니티 테이블
CREATE TABLE IF NOT EXISTS lectureCommunity (
    post_id INT AUTO_INCREMENT PRIMARY KEY,               -- 게시글 ID
    lecture_id INT NOT NULL,                              -- 강의 ID
    user_id VARCHAR(100) NOT NULL,                        -- 유저 ID
    post_title VARCHAR(255) NOT NULL,                     -- 게시글 제목
    post_content TEXT NOT NULL,                           -- 게시글 내용
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- 생성 날짜
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 퀴즈 정보 저장 테이블
DROP TABLE IF EXISTS quizzes;
CREATE TABLE IF NOT EXISTS quizzes (
    quizzes_no BIGINT AUTO_INCREMENT PRIMARY KEY,    -- 퀴즈의 고유 식별자
    quizzes_title VARCHAR(255) NOT NULL              -- 퀴즈 제목 저장
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 퀴즈 질문 정보 저장 테이블
DROP TABLE IF EXISTS questions;
CREATE TABLE IF NOT EXISTS questions(
    questions_no BIGINT AUTO_INCREMENT PRIMARY KEY,  -- 고유 식별자
    questions VARCHAR(255) NOT NULL,                 -- 각 질문
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_answer VARCHAR(255) NOT NULL             -- 정답 선택지
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 퀴즈와 질문 간의 연결 테이블
DROP TABLE IF EXISTS quizQuestions;
CREATE TABLE IF NOT EXISTS quizQuestions(
    quiz_no BIGINT NOT NULL,                         -- 퀴즈 고유 식별자
    question_no BIGINT NOT NULL,                     -- 질문의 고유 식별자
    PRIMARY KEY (quiz_no, question_no),              -- 기본 키 설정
    FOREIGN KEY (quiz_no) REFERENCES quizzes(quizzes_no) ON DELETE CASCADE,
    FOREIGN KEY (question_no) REFERENCES questions(questions_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 자료공유 테이블
DROP TABLE IF EXISTS datasharing;
CREATE TABLE IF NOT EXISTS datasharing(    
    data_no INT PRIMARY KEY AUTO_INCREMENT,
    data_name VARCHAR(100) NOT NULL,                      -- 자료 이름
    data_title VARCHAR(1000) NOT NULL,                    -- 자료 제목
    data_content LONG NOT NULL,                           -- 자료 내용
    data_date TIMESTAMP NOT NULL,                         -- 자료 날짜
    data_pw VARCHAR(1000) NOT NULL,                       -- 자료 비밀번호
    data_file VARCHAR(1000)                               -- 자료 파일
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 자료공유 댓글 테이블
DROP TABLE IF EXISTS datasharingcomment;
CREATE TABLE datasharingcomment (
  dsc_no INT AUTO_INCREMENT PRIMARY KEY,                  -- 댓글 ID
  ddno INT NOT NULL,                                      -- 자료 번호
  dsc_content TEXT NOT NULL,                              -- 댓글 내용
  dsc_writer VARCHAR(100) NOT NULL,                       -- 작성자
  dsc_time TIMESTAMP NOT NULL,                            -- 작성 시간
  CONSTRAINT reply_fk FOREIGN KEY (ddno) REFERENCES datasharing (data_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 커뮤니티 테이블
DROP TABLE IF EXISTS allcommunity;
CREATE TABLE IF NOT EXISTS allcommunity(    
    allc_no INT PRIMARY KEY AUTO_INCREMENT,                -- 커뮤니티 ID
    allc_name VARCHAR(100) NOT NULL,                      -- 커뮤니티 이름
    allc_title VARCHAR(1000) NOT NULL,                    -- 커뮤니티 제목
    allc_content LONG NOT NULL,                           -- 커뮤니티 내용
    allc_date TIMESTAMP                                  -- 커뮤니티 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 커뮤니티 댓글 테이블
DROP TABLE IF EXISTS communitycomment;
CREATE TABLE communitycomment (
  cmc_no INT AUTO_INCREMENT PRIMARY KEY,                  -- 댓글 ID
  cc_no INT NOT NULL,                                      -- 자료 번호
  cmc_content TEXT NOT NULL,                              -- 댓글 내용
  cmc_writer VARCHAR(100) NOT NULL,                       -- 작성자
  cmc_time TIMESTAMP NOT NULL,                            -- 작성 시간
  CONSTRAINT reply_fkk FOREIGN KEY (cc_no) REFERENCES allcommunity (allc_no) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 기존 외래 키 제약 조건 제거
ALTER TABLE communitycomment DROP FOREIGN KEY reply_fkk;

-- 새로운 외래 키 제약 조건 추가 (ON DELETE CASCADE)
ALTER TABLE communitycomment
ADD CONSTRAINT reply_fkk FOREIGN KEY (cc_no) REFERENCES allcommunity (allc_no) ON DELETE CASCADE;


-- 개인채팅 테이블
DROP TABLE IF EXISTS personal_chat;
CREATE TABLE IF NOT EXISTS personal_chat(    
    pchat_content LONG NOT NULL,                          -- 채팅 내용
    pchat_file VARCHAR(1000) NOT NULL,                    -- 채팅 파일
    pchat_date TIMESTAMP NOT NULL                         -- 채팅 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 단체채팅 테이블
DROP TABLE IF EXISTS group_chat;
CREATE TABLE IF NOT EXISTS group_chat(    
    gchat_nick VARCHAR(100) NOT NULL,                     -- 닉네임
    gchat_content1 LONG NOT NULL,                         -- 채팅 내용 1
    gchat_content2 LONG NOT NULL,                         -- 채팅 내용 2
    gchat_point VARCHAR(1000) NOT NULL,                   -- 채팅 포인트
    gchat_title VARCHAR(1000) NOT NULL,                   -- 채팅 제목
    gchat_date TIMESTAMP NOT NULL                         -- 채팅 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 챗봇 테이블
DROP TABLE IF EXISTS chatbot;
CREATE TABLE IF NOT EXISTS chatbot(
    id VARCHAR(20) PRIMARY KEY,                           -- 챗봇 ID
    name VARCHAR(10) NOT NULL,                            -- 챗봇 이름
    content VARCHAR(200) NOT NULL,                        -- 챗봇 내용
    reg_date TIMESTAMP NOT NULL                           -- 등록 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 챗봇 신청 테이블
DROP TABLE IF EXISTS chatbot_apply;
CREATE TABLE IF NOT EXISTS chatbot_apply(
    id VARCHAR(20) PRIMARY KEY,                           -- 챗봇 신청 ID
    name VARCHAR(10) NOT NULL,                            -- 이름
    content VARCHAR(200) NOT NULL,                        -- 내용
    reg_date TIMESTAMP NOT NULL                           -- 등록 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 챗봇 환불 테이블
DROP TABLE IF EXISTS chatbot_refund;
CREATE TABLE IF NOT EXISTS chatbot_refund(
    id VARCHAR(20) PRIMARY KEY,                           -- 챗봇 환불 ID
    name VARCHAR(10) NOT NULL,                            -- 이름
    content VARCHAR(200) NOT NULL,                        -- 내용
    reg_date TIMESTAMP NOT NULL                           -- 등록 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 챗봇 상담사 테이블
DROP TABLE IF EXISTS chatbot_counselor;
CREATE TABLE IF NOT EXISTS chatbot_counselor(
    id VARCHAR(20) PRIMARY KEY,                           -- 챗봇 상담사 ID
    name VARCHAR(10) NOT NULL,                            -- 이름
    content VARCHAR(200) NOT NULL,                        -- 내용
    reg_date TIMESTAMP NOT NULL                           -- 등록 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강의 질문 테이블
CREATE TABLE IF NOT EXISTS lectureQuestions (
    id INT AUTO_INCREMENT PRIMARY KEY,                    -- 질문 ID
    lecture_id INT NOT NULL,                              -- 강의 ID
    user_id VARCHAR(100) NOT NULL,                        -- 유저 ID
    content TEXT NOT NULL,                                -- 질문 내용
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- 생성 날짜
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강의 대답 테이블
CREATE TABLE IF NOT EXISTS lectureAnswers (
    id INT AUTO_INCREMENT PRIMARY KEY,                    -- 대답 ID
    question_id INT NOT NULL,                             -- 질문 ID
    instructor_id VARCHAR(100) NOT NULL,                  -- 강사 ID
    content TEXT NOT NULL,                                -- 대답 내용
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,       -- 생성 날짜
    FOREIGN KEY (question_id) REFERENCES lectureQuestions(id),
    FOREIGN KEY (instructor_id) REFERENCES user(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 수료증 테이블
CREATE TABLE IF NOT EXISTS certificate (
    certificate_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,  -- 수료증 ID
    user_id VARCHAR(100) NOT NULL,                           -- 사용자 ID
    lecture_id INT NOT NULL,                                 -- 강의 ID
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,          -- 발급 날짜
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 알림 테이블
DROP TABLE IF EXISTS notification;
CREATE TABLE notification (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,                  -- 알림 ID
    subject VARCHAR(255) NOT NULL,                         -- 주제
    user_name VARCHAR(20) NOT NULL,                        -- 사용자 이름
    exam_date DATE NOT NULL                                -- 시험 날짜
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 공지사항 테이블
DROP TABLE IF EXISTS notice;
CREATE TABLE IF NOT EXISTS notice (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,      -- 공지사항 ID
    title VARCHAR(255) NOT NULL,               -- 공지사항 제목
    content TEXT NOT NULL,                     -- 공지사항 내용
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 작성 일자
    user_id VARCHAR(100),                      -- 작성자 ID (user 테이블의 user_id를 참조)
    CONSTRAINT fk_notice_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 각 레코드의 기본 키(allc_no)를 미리 확인합니다.
UPDATE allcommunity SET allc_date = '2024-07-01 08:45:00' WHERE allc_no = 1;
UPDATE allcommunity SET allc_date = '2024-07-03 11:15:00' WHERE allc_no = 2;
UPDATE allcommunity SET allc_date = '2024-07-05 14:20:00' WHERE allc_no = 3;
UPDATE allcommunity SET allc_date = '2024-07-07 09:10:00' WHERE allc_no = 4;
UPDATE allcommunity SET allc_date = '2024-07-09 13:55:00' WHERE allc_no = 5;
UPDATE allcommunity SET allc_date = '2024-07-10 15:35:00' WHERE allc_no = 6;
UPDATE allcommunity SET allc_date = '2024-07-12 10:25:00' WHERE allc_no = 7;
UPDATE allcommunity SET allc_date = '2024-07-13 17:45:00' WHERE allc_no = 8;
UPDATE allcommunity SET allc_date = '2024-07-15 12:40:00' WHERE allc_no = 9;
UPDATE allcommunity SET allc_date = '2024-07-17 08:50:00' WHERE allc_no = 10;
