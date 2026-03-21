-- MVP migration for music forum
ALTER TABLE post
    ADD COLUMN song_name VARCHAR(200) NULL,
    ADD COLUMN artist VARCHAR(200) NULL,
    ADD COLUMN album VARCHAR(200) NULL,
    ADD COLUMN genre VARCHAR(100) NULL,
    ADD COLUMN tags VARCHAR(255) NULL,
    ADD COLUMN cover_url VARCHAR(500) NULL,
    ADD COLUMN music_url VARCHAR(500) NULL;

ALTER TABLE user
    ADD COLUMN music_preferences VARCHAR(500) NULL;

-- convert / seed music categories
UPDATE section SET section_name='流行', description='流行音乐分享与讨论', status=1 WHERE section_id=1;
UPDATE section SET section_name='摇滚', description='摇滚音乐分享与讨论', status=1 WHERE section_id=2;
UPDATE section SET section_name='民谣', description='民谣音乐分享与讨论', status=1 WHERE section_id=3;
UPDATE section SET section_name='说唱', description='说唱音乐分享与讨论', status=1 WHERE section_id=4;
UPDATE section SET section_name='电子', description='电子音乐分享与讨论', status=1 WHERE section_id=5;
INSERT INTO section(section_name, description, create_time, update_time, status)
SELECT '古典', '古典音乐分享与讨论', NOW(), NOW(), 1
WHERE NOT EXISTS (SELECT 1 FROM section WHERE section_name='古典');
INSERT INTO section(section_name, description, create_time, update_time, status)
SELECT '动漫', '动漫音乐分享与讨论', NOW(), NOW(), 1
WHERE NOT EXISTS (SELECT 1 FROM section WHERE section_name='动漫');
INSERT INTO section(section_name, description, create_time, update_time, status)
SELECT '其他', '其他风格音乐分享', NOW(), NOW(), 1
WHERE NOT EXISTS (SELECT 1 FROM section WHERE section_name='其他');

-- demo user preference
UPDATE user SET music_preferences='流行,民谣,治愈系' WHERE username='student1';

-- demo posts (idempotent by title)
INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 2, 1, '夜曲深夜循环推荐', '<p>旋律和弦乐非常有氛围，适合深夜安静时听。</p>', '夜曲', '周杰伦', '十一月的萧邦', '流行', '深夜,失恋,循环', 'https://images.unsplash.com/photo-1511379938547-c1f69419868d', 'https://music.163.com/#/song?id=185410', NOW(), 120, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='夜曲深夜循环推荐');

INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 3, 1, 'Blank Space 通勤必备', '<p>节奏明快，副歌抓耳，通勤路上特别提神。</p>', 'Blank Space', 'Taylor Swift', '1989', '流行', '通勤,热血,循环', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f', 'https://music.163.com/#/song?id=28949444', NOW(), 95, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='Blank Space 通勤必备');

INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 4, 3, '稻香 民谣感治愈推荐', '<p>歌词很有画面感，听完心情会变好。</p>', '稻香', '周杰伦', '魔杰座', '民谣', '治愈,学习,日常', 'https://images.unsplash.com/photo-1458560871784-56d23406c091', 'https://music.163.com/#/song?id=185809', NOW(), 88, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='稻香 民谣感治愈推荐');

INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 5, 4, 'Lose Yourself 健身热血单曲', '<p>说唱节奏和歌词都很燃，运动时非常带感。</p>', 'Lose Yourself', 'Eminem', '8 Mile', '说唱', '热血,健身,通勤', 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3', 'https://music.163.com/#/song?id=190072', NOW(), 73, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='Lose Yourself 健身热血单曲');

INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 2, 5, 'Stupid Love 电子舞曲推荐', '<p>节拍很适合跑步和派对，情绪值直接拉满。</p>', 'Stupid Love', 'Lady Gaga', 'Chromatica', '电子', '跑步,热血,派对', 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819', 'https://music.163.com/#/song?id=1431259432', NOW(), 61, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='Stupid Love 电子舞曲推荐');

INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 4, 6, '月光奏鸣曲古典入门', '<p>晚上学习时当背景音乐非常舒服，不会分心。</p>', 'Moonlight Sonata', 'Beethoven', 'Piano Sonata No.14', '古典', '学习,深夜,治愈', 'https://images.unsplash.com/photo-1507838153414-b4b713384a76', 'https://music.163.com/#/song?id=190137', NOW(), 54, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='月光奏鸣曲古典入门');

INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 3, 7, '残響散歌 动漫燃曲', '<p>高能段落很多，适合游戏和剪辑BGM。</p>', '残響散歌', 'Aimer', '残響散歌', '动漫', '热血,循环,二次元', 'https://images.unsplash.com/photo-1516280440614-37939bbacd81', 'https://music.163.com/#/song?id=1895134567', NOW(), 80, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='残響散歌 动漫燃曲');

INSERT INTO post(user_id, section_id, title, content, song_name, artist, album, genre, tags, cover_url, music_url, create_time, view_count, is_essence, status)
SELECT 5, 7, 'YOASOBI 夜に駆ける推荐', '<p>旋律抓耳、编曲层次丰富，循环听不腻。</p>', '夜に駆ける', 'YOASOBI', 'THE BOOK', '动漫', '通勤,深夜,循环', 'https://images.unsplash.com/photo-1497032628192-86f99bcd76bc', 'https://music.163.com/#/song?id=1409311773', NOW(), 67, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM post WHERE title='YOASOBI 夜に駆ける推荐');
