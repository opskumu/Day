#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import requests


def upload_baidu_api_data():
    """上传单个文件到百度云盘 < 2GB
    -----------------------------------------------------------------------------
    method              string  是      固定值，upload。
    access_token        string  是      开发者准入标识，HTTPS调用时必须使用。
    path                string  是      上传文件路径（含上传的文件名称)。
                                        上传文件路径一定是百度云盘提供路径，其它路径无效!
    file                char[]  是      上传文件的内容。
    ondup               string  否      overwrite：表示覆盖同名文件；
                                        newcopy：表示生成文件副本并进行重命名，命名规则为“文件名_日期.后缀”。
    -----------------------------------------------------------------------------
    """

    path = '云盘上传文件路径，必须是百度云指定 app 路径，一般为 /apps/pcstest_oauth/文件名'
    url = 'https://c.pcs.baidu.com/rest/2.0/pcs/file'
    params = {'method': 'upload',
              'access_token': access_token,
              'ondup': 'overwrite',
              'path': path}
    with open('本地上传文件路径(包含文件名称)', 'rb') as f:
        files = {'file': f}
        r = requests.post(url, params = params, files = files)

    print r.status_code, r.json()


if __name__ == '__main__':
    access_token = '你获取的 token (30 天过期)'
    upload_baidu_api_data()
