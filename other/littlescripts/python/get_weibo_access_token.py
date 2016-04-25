#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 获取微博 access_token，微博有 python sdk，也可直接通过 sdk 获取

import json
import requests

def get_url():
    params = {'client_id': APP_KEY,
              'response_type': 'code',
              'redirect_uri': CALLBACK_URL}
    r = requests.get(AUTHORIZE_URL, params=params)
    print(r.url)
    code = raw_input('拷贝以上链接输入浏览器填写 URL 获取 code [回车结束]: ')
    return code

def get_weibo_access_token():
    url = 'https://api.weibo.com/oauth2/access_token'
    params = {'client_id': APP_KEY,
              'client_secret': APP_SECRET,
              'grant_type': 'authorization_code',
              'code': CODE,
              'redirect_uri': CALLBACK_URL}

    r = requests.post(url, params=params)
    print r.status_code, r.json()

if __name__ == '__main__':
    APP_KEY = '待写入'      # 申请微博开发者，创建应用获取 APP KEY 和 APP SECRET
    APP_SECRET = '待写入'
    AUTHORIZE_URL = 'https://api.weibo.com/oauth2/authorize'
    CALLBACK_URL = 'http://opskumu.github.io'   # 和应用授权页面填写地址一样

    CODE = get_url()
    get_weibo_access_token()
