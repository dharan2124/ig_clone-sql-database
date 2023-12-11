# ig_clone-sql-database

## Overview

This repository contains a dataset designed to mimic a simplified version of an Instagram-like platform. The dataset is structured with tables representing users, photos, comments, likes, follows, tags, and their relationships. It can serve as a useful resource for database and analytics exploration.Finding the oldest and newest users.
Identifying inactive users who have never posted a photo.
Running contests to find the most-liked photos.
Calculating the average number of posts per user.
Discovering the top hashtags used in posts.
Detecting potential bots by finding users who liked every photo.
## Tables

Users:

id: Unique identifier for users.
username: Usernames for each user.

Photos:

id: Unique identifier for photos.
image_url: URL of the uploaded image.
user_id: Foreign key linking to the Users table.

Comments:

id: Unique identifier for comments.
comment_text: Text content of the comment.
photo_id: Foreign key linking to the Photos table.
user_id: Foreign key linking to the Users table.

Likes:

user_id: Foreign key linking to the Users table.
photo_id: Foreign key linking to the Photos table.

Follows:

follower_id: Foreign key linking to the Users table (follower).
followee_id: Foreign key linking to the Users table (followee).

Tags:

id: Unique identifier for tags.
tag_name: Unique names for tags.

Photo Tags:

photo_id: Foreign key linking to the Photos table.
tag_id: Foreign key linking to the Tags table.
