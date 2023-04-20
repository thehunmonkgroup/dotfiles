#!/usr/bin/env python3

import os
import sys
import logging
import yt_dlp
import tweepy
import requests
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

# NOTE: This was for independent user auth workflow, not needed now.
# def create_twitter_oauth():
#     oauth2_user_handler = tweepy.OAuth2UserHandler(
#         client_id=os.getenv("TWITTER_OAUTH_CLIENT_ID"),
#         client_secret=os.getenv("TWITTER_OAUTH_CLIENT_SECRET"),
#         redirect_uri="https://lifetolive.one",
#         scope=["tweet.read", "tweet.write", "offline.access"],
#     )
#     print(oauth2_user_handler.get_authorization_url())
#     auth_response_url = input("Enter authorization response URL: ")
#     auth_response_url = auth_response_url.strip()
#     access_token = oauth2_user_handler.fetch_token(auth_response_url)
#     print(f"Access token: {access_token}")

def create_twitter_client():
    client = tweepy.Client(
        consumer_key=os.getenv("TWITTER_API_CONSUMER_KEY"),
        consumer_secret=os.getenv("TWITTER_API_CONSUMER_SECRET"),
        access_token=os.getenv("TWITTER_ACCESS_TOKEN"),
        access_token_secret=os.getenv("TWITTER_ACCESS_TOKEN_SECRET"),
    )
    return client

def get_youtube_video_title(url):
    logger.info("Retreiving YouTube video title")
    ydl_opts = {'quiet': True}
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
        return info['title']
    except yt_dlp.utils.DownloadError as e:
        logger.error(f"Invalid YouTube URL: {url}: {e}")
        return False

def create_bitly_short_url(url, title):
    logger.info("Creating bit.ly short URL for YouTube video")
    headers = {
        'Authorization': f'Bearer {os.getenv("BITLY_API_KEY")}',
        'Content-Type': 'application/json'
    }
    data = {
        'long_url': url,
        'title': title,
    }
    session = requests.Session()
    retry = Retry(total=3, backoff_factor=1, status_forcelist=[429, 500, 502, 503, 504])
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('https://', adapter)
    session.mount('http://', adapter)
    response = session.post('https://api-ssl.bitly.com/v4/bitlinks', headers=headers, json=data)
    response.raise_for_status()
    short_url = response.json()['link']
    return short_url

def post_youtube_video_to_twitter(client, url, title):
    try:
        tweet = f"{title} {url}"
        client.create_tweet(text=tweet)
        logger.info(f"Successfully posted the YouTube video title and URL to Twitter\n\n{tweet}")
    except Exception as e:
        logger.error(f"Error posting YouTube video title and URL to Twitter: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        logger.error("Please provide a YouTube video URL as an argument")
        sys.exit(1)
    # NOTE: This was for independent user auth workflow, not needed now.
    # if sys.argv[1] == "--login":
    #     create_twitter_oauth()
    #     exit(0)
    youtube_url = sys.argv[1]
    title = get_youtube_video_title(youtube_url)
    if title:
        twitter_client = create_twitter_client()
        post_youtube_video_to_twitter(twitter_client, youtube_url, title)
        bitly_short_url = create_bitly_short_url(youtube_url, title)
        logger.info(f"Bitly short URL: {bitly_short_url}")
