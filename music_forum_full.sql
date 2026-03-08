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
(1, 'admin', '$2a$10$6e70YJTCnUGC3FB3dtDz.OPMk5bIwTf3CJ0iOL1AbduDMAKo82KWu', 'System Admin', 1, 'admin@musicforum.local', '13800000000', '/avatars/default.png', 'Forum admin', 'Administrator account', 'pop,rock,electronic', '2026-03-01 09:00:00', '2026-03-01 09:00:00', 1),
(2, 'demo_user', '$2a$10$6e70YJTCnUGC3FB3dtDz.OPMk5bIwTf3CJ0iOL1AbduDMAKo82KWu', 'Demo User', 2, 'demo@musicforum.local', '13900000001', '/avatars/default.png', 'Music all day', 'Demo account for presentation', 'jpop,indie,study', '2026-03-01 09:10:00', '2026-03-01 09:10:00', 1),
(3, 'music_lover', '$2a$10$6e70YJTCnUGC3FB3dtDz.OPMk5bIwTf3CJ0iOL1AbduDMAKo82KWu', 'Music Lover', 2, 'lover@musicforum.local', '13700000002', '/avatars/default.png', 'Loop playlist', 'Second demo account', 'late-night,chill', '2026-03-01 09:20:00', '2026-03-01 09:20:00', 1);

INSERT INTO `section` VALUES
(1, 'Pop', 'Popular songs and trending tracks', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(2, 'Rock', 'Rock classics and modern rock', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(3, 'Folk', 'Acoustic and folk sharing', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(4, 'Rap', 'Hip-hop and rap discussion', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(5, 'Electronic', 'EDM and electronic vibes', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(6, 'Classical', 'Classical and instrumental music', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(7, 'Anime', 'Anime songs and soundtrack', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1),
(8, 'Other', 'Other genres and mixed playlists', '2026-03-01 10:00:00', '2026-03-01 10:00:00', 1);

INSERT INTO `post` VALUES
(1, 2, 1, 'Late-night healing single recommendation', 'Great for late-night study.', 'Blue', 'Aimer', 'Walpurgis', 'Pop', 'healing,late-night,study,loop', 'https://images.unsplash.com/photo-1511379938547-c1f69419868d', 'https://www.youtube.com/watch?v=YqfA1mM6f6U', '2026-03-02 20:10:00', '2026-03-02 20:10:00', 96, 1, 1),
(2, 2, 2, 'Classic rock power track', 'This one boosts coding energy.', 'Bohemian Rhapsody', 'Queen', 'A Night at the Opera', 'Rock', 'classic,energy,commute', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f', 'https://www.youtube.com/watch?v=fJ9rUzIMcZQ', '2026-03-02 21:00:00', '2026-03-02 21:00:00', 133, 1, 1),
(3, 3, 3, 'Folk guitar for rainy day', 'Simple arrangement and touching vocal.', 'Li Bai', 'Zhao Lei', 'N/A', 'Folk', 'rainy-day,healing,acoustic', 'https://images.unsplash.com/photo-1461783436728-0a9217714694', 'https://www.youtube.com/watch?v=7E9Ed9DUQoQ', '2026-03-03 10:25:00', '2026-03-03 10:25:00', 57, 0, 1),
(4, 3, 4, 'Rap song with storytelling', 'Strong lyrics and rhythm for workout.', 'Numb Encore', 'Jay-Z, Linkin Park', 'Collision Course', 'Rap', 'gym,hype,storytelling', 'https://images.unsplash.com/photo-1516280440614-37939bbacd81', 'https://www.youtube.com/watch?v=dlFA0Zq1k2A', '2026-03-03 12:00:00', '2026-03-03 12:00:00', 71, 0, 1),
(5, 2, 5, 'Electronic track for running', 'Steady BPM and clean synth.', 'Titanium', 'David Guetta, Sia', 'Nothing but the Beat', 'Electronic', 'running,workout,bpm', 'https://images.unsplash.com/photo-1571266028243-d220c6f5d9f3', 'https://www.youtube.com/watch?v=JRfuAukYTKg', '2026-03-03 17:45:00', '2026-03-03 17:45:00', 109, 0, 1),
(6, 3, 6, 'Classical piano for focus', 'A calm piece for reading.', 'Nocturne Op9 No2', 'Chopin', 'N/A', 'Classical', 'focus,reading,calm', 'https://images.unsplash.com/photo-1507838153414-b4b713384a76', 'https://www.youtube.com/watch?v=9E6b3swbnWg', '2026-03-04 09:30:00', '2026-03-04 09:30:00', 64, 0, 1),
(7, 2, 7, 'Anime opening that never gets old', 'Great for morning commute.', 'Gurenge', 'LiSA', 'LEO-NiNE', 'Anime', 'anime,hot-blooded,commute', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745', 'https://www.youtube.com/watch?v=CwkzK-F0Y00', '2026-03-04 18:05:00', '2026-03-04 18:05:00', 144, 1, 1),
(8, 3, 8, 'Loop-worthy pop track', 'Sharing for commute and study.', 'Cruel Summer', 'Taylor Swift', 'Lover', 'Pop', 'commute,study,loop', 'https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec', 'https://www.youtube.com/watch?v=ic8j13piAhQ', '2026-03-04 19:30:00', '2026-03-04 19:30:00', 88, 0, 1),
(9, 2, 1, 'Chinese pop mood song', 'Good songwriting and arrangement.', 'Qing Tian', 'Jay Chou', 'Yeh Hui Mei', 'Pop', 'nostalgia,late-night,loop', 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1', 'https://www.youtube.com/watch?v=DYptgVvkVLQ', '2026-03-05 20:10:00', '2026-03-05 20:10:00', 155, 1, 1),
(10, 2, 1, 'J-pop recommendation for study', 'Bright melody and stable rhythm.', 'Yoru ni Kakeru', 'YOASOBI', 'THE BOOK', 'Pop', 'jpop,study,daily,loop', 'https://images.unsplash.com/photo-1506157786151-b8491531f063', 'https://www.youtube.com/watch?v=x8VYWazR5mE', '2026-03-05 21:00:00', '2026-03-05 21:00:00', 111, 0, 1);

INSERT INTO `comment` VALUES
(1, 1, 3, 'This one is in my study playlist too.', '2026-03-02 21:00:00', NULL, 1),
(2, 2, 3, 'Rock classic, no skip.', '2026-03-02 21:30:00', NULL, 1),
(3, 7, 2, 'Anime OP always gives me energy.', '2026-03-04 18:30:00', NULL, 1),
(4, 1, 2, 'Agreed. Vocal details are amazing.', '2026-03-02 22:00:00', 1, 1),
(5, 9, 3, 'Still top level nostalgia.', '2026-03-05 20:40:00', NULL, 1);

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
(1, 'Music Forum Launched', 'Welcome to the new music sharing forum.', 1, '2026-03-01 12:00:00', 1);

INSERT INTO `report` VALUES
(1, 3, 1, 8, 'Suspected wrong external link', '2026-03-05 22:00:00', 1, '2026-03-05 22:30:00', 1);

INSERT INTO `resource_category` VALUES
(1, 'Music Scores', 'Piano and guitar sheet resources', '2026-03-01 11:00:00', 1),
(2, 'Learning Materials', 'Music theory and arrangement docs', '2026-03-01 11:00:00', 1),
(3, 'Tools', 'Music production tools and templates', '2026-03-01 11:00:00', 1);

INSERT INTO `resource` VALUES
(1, 'Basic Chord Progression Notes', 'Common pop chord progressions.', '/resources/chord_progressions.pdf', 1024, 'pdf', 2, 2, 12, '2026-03-03 08:00:00', 1),
(2, 'EDM Kick Starter Pack', 'Demo sample pack for beginner beat making.', '/resources/edm_kick_pack.zip', 20480, 'zip', 3, 3, 8, '2026-03-03 09:00:00', 1);

INSERT INTO `section_moderator` VALUES
(1, 1, 2, '2026-03-01 12:00:00', 1, 1, 'Pop section helper'),
(2, 7, 3, '2026-03-01 12:10:00', 1, 1, 'Anime section helper');

SET FOREIGN_KEY_CHECKS = 1;
