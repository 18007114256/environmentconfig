var fs = window.require("fs");
var stat = fs.stat;
/******************************自定义方法 start**************************************/
/**
 * 根据key获取cookie的值
 * @param {Object} key
 */
export function getCookie(key) {
    var str = document.cookie; // 获取Cookie字符串
    if (!str || str.indexOf(key + "=") < 0) {
        // 寻找name=
        return;
    }
    var cookies = str.split("; "); // 用;将所有的Cookie分隔开
    for (var i = 0; i < cookies.length; i++) {
        // 遍历每个Cookie
        var cookie = cookies[i]; // 当前Cookie
        if (cookie.indexOf(key + "=") == 0) {
            // 如果名字为name
            var value = cookie.substring(key.length + 1); // 获取value
            return decodeURI(value); // 将value解码，并返回
        }
    }
}

/**
 * 设置cookie
 * @param {Object} key      key
 * @param {Object} value       值
 * @param {Object} expiredays  失效时间
 */
export function setCookie(key, value, expiredays) {
    var exdate = new Date();
    exdate.setDate(exdate.getDate() + expiredays);
    document.cookie =
        key +
        "=" +
        encodeURI(value) +
        (expiredays == null ? "" : ";expires=" + exdate.toGMTString() + ";path=/");
}

/**
 * 删除cookie
 * @param {Object} key
 */
export function delCookie(key) {
    var curVal = getCookie(key);
    var exp = new Date();
    exp.setTime(exp.getTime() - 10);
    if (null != curVal) {
        document.cookie = key + "=" + encodeURI(curVal) + ";expires=" + exp.toGMTString();
    }
}
/**
 * 设置storage
 * @param {Object} key
 * @param {Object} value
 */
export function setStorage(key, value) {
    if (window.localStorage) {
        var storage = window.localStorage;
        storage.setItem(key, value);
    } else {
        setCookie(key, value);
    }
}

/**
 * 获取storage
 * @param {Object} key
 */
export function getStorage(key) {
    if (window.localStorage) {
        var storage = window.localStorage;
        if (
            "undefined" != typeof storage.getItem(key) &&
            null != storage.getItem(key) &&
            "" != storage.getItem(key)
        ) {
            return storage.getItem(key);
        } else {
            return "";
        }
    } else {
        getCookie(key);
    }
}
/**
 * 删除storage
 * @param {Object} key
 */
export function deleteStorage(key) {
    if (window.localStorage) {
        localStorage.removeItem(key);
    } else {
        delCookie(key);
    }
}

/**
 * 模糊删除storage
 * @param {Object} key
 */
export function deleteStorageByName(key) {
    if (window.localStorage) {
        for (var i = 0; i < localStorage.length; i++) {
            var storageKey = localStorage.key(i);
            if (storageKey.indexOf(key) > -1) {
                localStorage.removeItem(storageKey);
                i--;
            }
        }
    } else {
        delCookie(key);
    }
}

export function copy(src, dst) {
    //读取目录
    fs.readdir(src, function (err, paths) {
        console.log(paths);
        if (err) {
            throw err;
        }
        paths.forEach(function (path) {
            var _src = src + "/" + path;
            var _dst = dst + "/" + path;
            var readable;
            var writable;
            stat(_src, function (err, st) {
                if (err) {
                    throw err;
                }

                if (st.isFile()) {
                    readable = fs.createReadStream(_src); //创建读取流
                    writable = fs.createWriteStream(_dst); //创建写入流
                    readable.pipe(writable);
                } else if (st.isDirectory()) {
                    exists(_src, _dst, copy);
                }
            });
        });
    });
}

export function exists(src, dst, callback) {
    //测试某个路径下文件是否存在
    fs.exists(dst, function (exists) {
        if (exists) {
            //不存在
            callback(src, dst);
        } else {
            //存在
            fs.mkdir(dst, function () {
                //创建目录
                callback(src, dst);
            });
        }
    });
}
