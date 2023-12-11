-- 1. Create an ER diagram or draw a schema for the given database.

-- image in zip file.


-- 2. We want to reward the user who has been around the longest, Find the 5 oldest users.

use ig_clone;

select * from users
order by created_at
limit 5;


-- 3. To target inactive users in an email ad campaign, find the users who have never posted a photo.

select username,photos.id,image_url
from users
left join photos on users.id = photos.user_id
where photos.id is null;


-- 4. Suppose you are running a contest to find out who got the most likes on a photo. 
-- Find out who won?


with cte as(select p.id,u.username,p.image_url,count(l.user_id) total 
from photos p inner join likes l on p.id=l.photo_id
inner join users u on p.user_id=u.id 
group by p.id)
select * from cte where total=(select max(total) from cte);

-- or --

SELECT photos.id,users.username,photos.image_url,COUNT(*) AS Total
FROM photos
JOIN likes ON photos.id = likes.photo_id
JOIN users ON users.id = photos.user_id
GROUP BY photos.id
ORDER BY Total DESC
LIMIT 1;


-- 5. The investors want to know how many times does the average user post.

 SELECT 
      (SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users) AS avg;
    

-- 6. A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.

select t.id,t.tag_name,COUNT(*) as total
from photo_tags pt join tags t
on pt.tag_id= t.id
group by t.id
order by total desc
limit 5;

-- or --

WITH TagRank AS (
    SELECT t.id, t.tag_name, COUNT(*) AS total,
           RANK() OVER (ORDER BY COUNT(*) DESC) AS tag_rank
    FROM photo_tags pt
    JOIN tags t ON pt.tag_id = t.id
    GROUP BY t.id
    order by total desc
)
SELECT id, tag_name, total
FROM TagRank
WHERE tag_rank <= 5;


-- 7. To find out if there are bots, find users who have liked every single photo on the site.


select users.id,username, count(*) as total_likes
from users inner join likes on users.id = likes.user_id
group by users.id
having total_likes = (select count(*) from photos);


-- 8. Find the users who have created instagram id in may and select top 5 newest joinees from it?


select username,created_at from users 
where month(created_at)=5 
order by created_at desc limit 5;

-- or--

WITH UserRank AS (
    SELECT username, created_at,
           ROW_NUMBER() OVER (ORDER BY created_at DESC) AS user_rank
    FROM users
    WHERE MONTH(created_at) = 5
)
SELECT username, created_at
FROM UserRank
WHERE user_rank <= 5;


-- 9. Can you help me find the users whose name starts with c and ends with any number and 
  -- have posted the photos as well as liked the photos?


select distinct u.id,u.username from photos p inner join users u on p.user_id=u.id
inner join likes l on l.user_id=u.id
where username regexp '^[c].*[123456789]$';


-- 10. Demonstrate the top 30 usernames to the company who have posted photos in the range of 3 to 5.


select u.id,username,count(u.id) posted
from users u 
join photos p on u.id = p.user_id
group by u.id
having posted between 3 and 5
order by posted desc limit 30;

-- or --

WITH UserPostRank AS (
    SELECT u.id, username, COUNT(p.id) AS posted,
           ROW_NUMBER() OVER (ORDER BY COUNT(p.id) DESC) AS user_rank
    FROM users u
    JOIN photos p ON u.id = p.user_id
    GROUP BY u.id, username
    HAVING posted BETWEEN 3 AND 5
)
SELECT id, username, posted
FROM UserPostRank
WHERE user_rank <= 30;

-- 11.  Display the top 5 users with the most comments on their photos:

SELECT u.username, COUNT(c.id) AS comment_count
FROM users u
JOIN photos p ON u.id = p.user_id
LEFT JOIN comments c ON p.id = c.photo_id
GROUP BY u.username
ORDER BY comment_count DESC
LIMIT 5;

-- or -- 

WITH UserCommentRank AS (
    SELECT u.username, COUNT(c.id) AS comment_count,
           DENSE_RANK() OVER (ORDER BY COUNT(c.id) DESC) AS user_rank
    FROM users u
    JOIN photos p ON u.id = p.user_id
    LEFT JOIN comments c ON p.id = c.photo_id
    GROUP BY u.username
)
SELECT username, comment_count
FROM UserCommentRank
WHERE user_rank <= 5;

-- 12. Find users who have posted photos and liked photos with more than 10 likes 

SELECT DISTINCT u.username,COUNT(l.user_id) as likecount
FROM users u
JOIN photos p ON u.id = p.user_id
JOIN likes l ON p.id = l.photo_id
GROUP BY u.username, p.id
HAVING likecount > 10
order by likecount desc;

-- 13. Find the average number of comments per photo

SELECT AVG(comment_count) AS avg_comments_per_photo
FROM (SELECT p.id, COUNT(c.id) AS comment_count
      FROM photos p
      LEFT JOIN comments c ON p.id = c.photo_id
      GROUP BY p.id) AS photo_comments;

-- 14. Display the top 5 users who have the most followers

WITH UserFollowerRank AS (
    SELECT
        u.username,
        COUNT(f.follower_id) AS follower_count,
        DENSE_RANK() OVER (ORDER BY COUNT(f.follower_id) DESC) AS user_rank
    FROM users u LEFT JOIN follows f ON u.id = f.followee_id
    GROUP BY u.id, u.username
)
SELECT
    username,
    follower_count FROM
    UserFollowerRank
WHERE user_rank <= 5;

-- 15. Calculate the growth rate of users joining each month:

 DELIMITER //       
 CREATE PROCEDURE CalculateUserGrowthRate()
BEGIN
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS month_year,
        COUNT(id) AS new_users,
        LAG(COUNT(id)) OVER (ORDER BY MIN(created_at)) AS prev_month_users,
        (COUNT(id) - LAG(COUNT(id)) OVER (ORDER BY MIN(created_at))) / LAG(COUNT(id)) OVER (ORDER BY MIN(created_at)) * 100 AS growth_rate
    FROM
        users
    GROUP BY
        month_year;
END //

CALL CalculateUserGrowthRate();


-- 16.  Find the users who have the highest engagement rate (likes per post) using a stored procedure

-- Assuming the stored procedure calculates engagement rate

DELIMITER //

CREATE PROCEDURE GetTopEngagedUsers()
BEGIN
    SELECT
        u.username,
        AVG(l.user_id) AS engagement_rate
    FROM
        users u
    LEFT JOIN
        photos p ON u.id = p.user_id
    LEFT JOIN
        likes l ON p.id = l.photo_id
    GROUP BY
        u.username
    ORDER BY
        engagement_rate DESC
    LIMIT 5;
END //

CALL GetTopEngagedUsers();
