SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS `music_forum`;
CREATE DATABASE `music_forum` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `music_forum`;

DROP TABLE IF EXISTS `comment_like`;
DROP TABLE IF EXISTS `post_favorite`;
DROP TABLE IF EXISTS `section_moderator`;
DROP TABLE IF EXISTS `comment`;
DROP TABLE IF EXISTS `report`;
DROP TABLE IF EXISTS `notification`;
DROP TABLE IF EXISTS `resource`;
DROP TABLE IF EXISTS `resource_category`;
DROP TABLE IF EXISTS `post`;
DROP TABLE IF EXISTS `section`;
DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(100) NOT NULL,
  `real_name` varchar(50) DEFAULT NULL,
  `role` int NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `signature` varchar(200) DEFAULT NULL,
  `profile` text,
  `music_preferences` varchar(500) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `update_time` datetime DEFAULT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `section` (
  `section_id` int NOT NULL AUTO_INCREMENT,
  `section_name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `update_time` datetime DEFAULT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`section_id`),
  UNIQUE KEY `idx_section_name` (`section_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `post` (
  `post_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `section_id` int NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` longtext NOT NULL,
  `song_name` varchar(200) DEFAULT NULL,
  `artist` varchar(200) DEFAULT NULL,
  `album` varchar(200) DEFAULT NULL,
  `genre` varchar(100) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `cover_url` varchar(500) DEFAULT NULL,
  `music_url` varchar(500) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `update_time` datetime DEFAULT NULL,
  `view_count` int NOT NULL DEFAULT 0,
  `is_essence` int NOT NULL DEFAULT 0,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_section_id` (`section_id`),
  KEY `idx_create_time` (`create_time`),
  CONSTRAINT `fk_post_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_post_section` FOREIGN KEY (`section_id`) REFERENCES `section` (`section_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `comment` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text NOT NULL,
  `create_time` datetime NOT NULL,
  `parent_id` int DEFAULT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`comment_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_id` (`parent_id`),
  CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `comment` (`comment_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `comment_like` (
  `id` int NOT NULL AUTO_INCREMENT,
  `comment_id` int NOT NULL,
  `user_id` int NOT NULL,
  `create_time` datetime NOT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_comment_user` (`comment_id`, `user_id`),
  KEY `idx_comment_like_user` (`user_id`),
  CONSTRAINT `fk_like_comment` FOREIGN KEY (`comment_id`) REFERENCES `comment` (`comment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `post_favorite` (
  `id` int NOT NULL AUTO_INCREMENT,
  `post_id` int NOT NULL,
  `user_id` int NOT NULL,
  `create_time` datetime NOT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_post_user` (`post_id`, `user_id`),
  KEY `idx_post_favorite_user` (`user_id`),
  CONSTRAINT `fk_favorite_post` FOREIGN KEY (`post_id`) REFERENCES `post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_favorite_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `notification` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `user_id` int NOT NULL,
  `create_time` datetime NOT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`notification_id`),
  KEY `idx_notification_user` (`user_id`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `report` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `type` int NOT NULL,
  `target_id` int NOT NULL,
  `reason` varchar(500) NOT NULL,
  `create_time` datetime NOT NULL,
  `handler_id` int DEFAULT NULL,
  `handle_time` datetime DEFAULT NULL,
  `status` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`report_id`),
  KEY `idx_report_user` (`user_id`),
  KEY `idx_report_handler` (`handler_id`),
  CONSTRAINT `fk_report_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_report_handler` FOREIGN KEY (`handler_id`) REFERENCES `user` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `resource_category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `create_time` datetime NOT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `idx_category_name` (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `resource` (
  `resource_id` int NOT NULL AUTO_INCREMENT,
  `resource_name` varchar(200) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_size` int NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `user_id` int NOT NULL,
  `category_id` int NOT NULL,
  `download_count` int NOT NULL DEFAULT 0,
  `create_time` datetime NOT NULL,
  `status` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`resource_id`),
  KEY `idx_resource_user` (`user_id`),
  KEY `idx_resource_category` (`category_id`),
  CONSTRAINT `fk_resource_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_resource_category` FOREIGN KEY (`category_id`) REFERENCES `resource_category` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `section_moderator` (
  `id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `user_id` int NOT NULL,
  `appoint_time` datetime NOT NULL,
  `appoint_by` int NOT NULL,
  `status` int NOT NULL DEFAULT 1,
  `remark` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_section_user` (`section_id`, `user_id`),
  KEY `idx_section_moderator_user` (`user_id`),
  KEY `idx_section_moderator_appoint_by` (`appoint_by`),
  CONSTRAINT `fk_moderator_section` FOREIGN KEY (`section_id`) REFERENCES `section` (`section_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_moderator_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_moderator_appoint` FOREIGN KEY (`appoint_by`) REFERENCES `user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `user` VALUES
(1, 'admin', '$2a$10$6e70YJTCnUGC3FB3dtDz.OPMk5bIwTf3CJ0iOL1AbduDMAKo82KWu', '系统管理员', 1, 'admin@musicforum.local', '13800000000', '/avatars/default.png', '欢迎来到音乐论坛', '平台管理员账号', '流行,摇滚,电子', '2026-03-01 09:00:00', '2026-03-01 09:00:00', 1),
(2, 'demo_user', '$2a$10$6e70YJTCnUGC3FB3dtDz.OPMk5bIwTf3CJ0iOL1AbduDMAKo82KWu', '演示用户', 2, 'demo@musicforum.local', '13900000001', '/avatars/default.png', '每天都在循环好歌', '用于答辩演示的普通账号', 'JPOP,独立,学习歌单', '2026-03-01 09:10:00', '2026-03-01 09:10:00', 1),
(3, 'music_lover', '$2a$10$6e70YJTCnUGC3FB3dtDz.OPMk5bIwTf3CJ0iOL1AbduDMAKo82KWu', '乐迷用户', 2, 'lover@musicforum.local', '13700000002', '/avatars/default.png', '深夜听歌爱好者', '用于演示的第二个普通账号', '深夜,治愈,通勤', '2026-03-01 09:20:00', '2026-03-01 09:20:00', 1);

INSERT INTO `section` VALUES
(1, '流行', '热门流行歌曲与新歌分享', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(2, '摇滚', '经典摇滚与现代摇滚交流', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(3, '民谣', '木吉他与民谣歌曲分享', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(4, '说唱', '嘻哈与说唱作品讨论', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(5, '电子', '电音与合成器风格交流', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(6, '古典', '古典与纯音乐推荐', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(7, '动漫', '动漫歌曲与配乐分享', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(8, '其他', '其他风格与综合歌单', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1);

INSERT INTO `post` VALUES
(1, 2, 1, '深夜治愈单曲推荐', '这首歌很适合深夜学习时循环，情绪非常稳定。', 'Blue', 'Aimer', 'Walpurgis', '流行', '治愈,深夜,学习,循环', 'https://images.unsplash.com/photo-1511379938547-c1f69419868d', 'https://www.youtube.com/watch?v=YqfA1mM6f6U', '2026-03-02 20:10:00', '2026-03-02 20:10:00', 96, 1, 1),
(2, 2, 2, '经典摇滚通勤神曲', '节奏和情绪都很强，写代码和通勤都很好用。', 'Bohemian Rhapsody', 'Queen', 'A Night at the Opera', '摇滚', '经典,热血,通勤', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f', 'https://www.youtube.com/watch?v=fJ9rUzIMcZQ', '2026-03-02 21:00:00', '2026-03-02 21:00:00', 133, 1, 1),
(3, 3, 3, '雨天必听民谣吉他', '编曲简单但人声很打动人，适合安静听。', '李白', 'Zhao Lei', '', '民谣', '雨天,治愈,木吉他', 'https://images.unsplash.com/photo-1461783436728-0a9217714694', 'https://www.youtube.com/watch?v=7E9Ed9DUQoQ', '2026-03-03 10:25:00', '2026-03-03 10:25:00', 57, 0, 1),
(4, 3, 4, '叙事感很强的说唱', '歌词信息量大，节奏适合运动时听。', 'Numb Encore', 'Jay-Z, Linkin Park', 'Collision Course', '说唱', '健身,热血,叙事', 'https://images.unsplash.com/photo-1516280440614-37939bbacd81', 'https://www.youtube.com/watch?v=dlFA0Zq1k2A', '2026-03-03 12:00:00', '2026-03-03 12:00:00', 71, 0, 1),
(5, 2, 5, '跑步向电子音乐推荐', 'BPM稳定，合成器层次清晰，适合有氧。', 'Titanium', 'David Guetta, Sia', 'Nothing but the Beat', '电子', '跑步,运动,BPM', 'https://images.unsplash.com/photo-1571266028243-d220c6f5d9f3', 'https://www.youtube.com/watch?v=JRfuAukYTKg', '2026-03-03 17:45:00', '2026-03-03 17:45:00', 109, 0, 1),
(6, 3, 6, '专注阅读用古典钢琴', '旋律平稳，不抢注意力，读论文很合适。', 'Nocturne Op9 No2', 'Chopin', '', '古典', '专注,阅读,安静', 'https://images.unsplash.com/photo-1507838153414-b4b713384a76', 'https://www.youtube.com/watch?v=9E6b3swbnWg', '2026-03-04 09:30:00', '2026-03-04 09:30:00', 64, 0, 1),
(7, 2, 7, '多年不过时的动漫OP', '前奏一出就有画面感，早晨通勤很提神。', 'Gurenge', 'LiSA', 'LEO-NiNE', '动漫', '动漫,热血,通勤', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745', 'https://www.youtube.com/watch?v=CwkzK-F0Y00', '2026-03-04 18:05:00', '2026-03-04 18:05:00', 144, 1, 1),
(8, 3, 8, '循环耐听的流行单曲', '分享一首适合学习和通勤的流行歌。', 'Cruel Summer', 'Taylor Swift', 'Lover', '流行', '通勤,学习,循环', 'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec', 'https://www.youtube.com/watch?v=ic8j13piAhQ', '2026-03-04 19:30:00', '2026-03-04 19:30:00', 88, 0, 1),
(9, 2, 1, '华语流行氛围推荐', '旋律和编曲都很完整，适合晚上反复听。', '晴天', 'Jay Chou', 'Yeh Hui Mei', '流行', '怀旧,深夜,循环', 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1', 'https://www.youtube.com/watch?v=DYptgVvkVLQ', '2026-03-05 20:10:00', '2026-03-05 20:10:00', 155, 1, 1),
(10, 2, 1, '学习向J-POP推荐', '旋律明亮、节奏稳定，做背景音乐很舒服。', '夜に駆ける', 'YOASOBI', 'THE BOOK', '流行', 'JPOP,学习,日常,循环', 'https://images.unsplash.com/photo-1506157786151-b8491531f063', 'https://www.youtube.com/watch?v=x8VYWazR5mE', '2026-03-05 21:00:00', '2026-03-05 21:00:00', 111, 0, 1);

INSERT INTO `comment` VALUES
(1, 1, 3, '这首我也放在学习歌单里，真的很治愈。', '2026-03-02 21:00:00', NULL, 1),
(2, 2, 3, '摇滚经典，基本不跳过。', '2026-03-02 21:30:00', NULL, 1),
(3, 7, 2, '动漫OP太提神了，早上通勤必听。', '2026-03-04 18:30:00', NULL, 1),
(4, 1, 2, '同意，人声细节很有层次。', '2026-03-02 22:00:00', 1, 1),
(5, 9, 3, '这一首真的很有怀旧氛围。', '2026-03-05 20:40:00', NULL, 1);

INSERT INTO `comment_like` VALUES
(1, 1, 2, '2026-03-02 21:10:00', 1),
(2, 2, 2, '2026-03-02 21:35:00', 1),
(3, 3, 3, '2026-03-04 18:32:00', 1);

INSERT INTO `post_favorite` VALUES
(1, 1, 3, '2026-03-02 21:20:00', 1),
(2, 2, 3, '2026-03-02 21:40:00', 1),
(3, 7, 2, '2026-03-04 18:40:00', 1),
(4, 9, 3, '2026-03-05 20:45:00', 1);

INSERT INTO `notification` VALUES
(1, '音乐论坛已上线', '欢迎来到音乐资源分享交流论坛，快来发布你的第一篇音乐分享帖。', 1, '2026-03-01 12:00:00', 1);

INSERT INTO `report` VALUES
(1, 3, 1, 8, '疑似外链地址异常', '2026-03-05 22:00:00', 1, '2026-03-05 22:30:00', 1);

INSERT INTO `resource_category` VALUES
(1, '乐谱资源', '钢琴与吉他等乐谱资料', '2026-03-01 11:00:00', 1),
(2, '学习资料', '乐理与编曲相关文档', '2026-03-01 11:00:00', 1),
(3, '制作工具', '音乐制作工具与模板', '2026-03-01 11:00:00', 1);

INSERT INTO `resource` VALUES
(1, '常见和弦进行笔记', '整理了流行音乐常见和弦进行。', '/resources/chord_progressions.pdf', 1024, 'pdf', 2, 2, 12, '2026-03-03 08:00:00', 1),
(2, '电子鼓组入门包', '适合初学者打节拍的示例采样包。', '/resources/edm_kick_pack.zip', 20480, 'zip', 3, 3, 8, '2026-03-03 09:00:00', 1);

INSERT INTO `section_moderator` VALUES
(1, 1, 2, '2026-03-01 12:00:00', 1, 1, '流行板块协助管理'),
(2, 7, 3, '2026-03-01 12:10:00', 1, 1, '动漫板块协助管理');

SET FOREIGN_KEY_CHECKS = 1;
