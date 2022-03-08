"use strict";

import {
    app,
    protocol,
    BrowserWindow,
    Menu,
    ipcMain,
    Tray,
    globalShortcut,
    dialog,
} from "electron";
import { createProtocol } from "vue-cli-plugin-electron-builder/lib";
import installExtension, { VUEJS_DEVTOOLS } from "electron-devtools-installer";

const isDevelopment = process.env.NODE_ENV !== "production";
const path = require("path");
const url = require("url");
const fs = require("fs");
const editDirFun = require("./utils/index");
const oldEditDirFun = require("./utils/oldIndex");
const internalIp = require("internal-ip");
const open = require("open");
const iconv = require("iconv-lite");
const projectStatus = Object.freeze({
    bizmate: 101, // 伴正事
    yqt: 102, // 银企通
    mPaas: 201, // mpaas
    Tchat: 202, // 原生
});

// const httpServer = require("http-server");
// if (isDevelopment) {
//     console.log("本地");
//     httpServer.createServer().listen(8889);
// } else {
//     console.log("线上");
//     httpServer.createServer({ root: __dirname }).listen(8888);
// }

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWinow;

// Scheme must be registered before the app is ready
protocol.registerSchemesAsPrivileged([
    { scheme: "app", privileges: { secure: true, standard: true } },
]);

function createWindow() {
    // Create the browser window.
    // let width = process.env.CURRENT_PRO == "pluginScpmock" ? 580 : 400;
    // let maxWidth = process.env.CURRENT_PRO == "pluginScpmock" ? 580 : 400;
    // let width = 430;
    // let maxWidth = 530;
    mainWinow = new BrowserWindow({
        frame: false,
        useContentSize: true,
        // width: maxWidth,
        // height: 620,
        // minWidth: width,
        // minHeight: 600,
        width: 750,
        height: 580,
        minWidth: 750,
        minHeight: 580,
        webPreferences: {
            // Use pluginOptions.nodeIntegration, leave this alone
            // See nklayman.github.io/vue-cli-plugin-electron-builder/guide/security.html#node-integration for more info
            nodeIntegration: true,
            // preload: path.join(__dirname, '../public/renderer.js'),
            // nodeIntegration: process.env.ELECTRON_NODE_INTEGRATION,
            webSecurity: false,
            enableRemoteModule: true,
            webviewTag: true
        },
        // icon: `${__static}/app.ico`
    });

    if (process.env.WEBPACK_DEV_SERVER_URL) {
        // Load the url of the dev server if in development mode
        mainWinow.loadURL(process.env.WEBPACK_DEV_SERVER_URL);
        // if (!process.env.IS_TEST)
        // mainWinow.webContents.openDevTools({ mode: "detach" });
    } else {
        createProtocol("app");
        // Load the index.html when not in development
        mainWinow.loadURL("app://./index.html");
        // mainWinow.webContents.openDevTools({ mode: "detach" });
    }
    mainWinow.hookWindowMessage(278, (e) => {
        mainWinow.setEnabled(false); //窗口禁用
        setTimeout(() => {
            mainWinow.setEnabled(true);
        }, 100);
        return true;
    });
    globalShortcut.register("Alt+w", function () {
        if (mainWinow.isMinimized()) {
            mainWinow.restore();
            mainWinow.show();
            mainWinow.focus();
        } else {
            mainWinow.minimize();
            mainWinow.hide();
        }
    });
    mainWinow.on("closed", () => {
        mainWinow = null;
    });

    createMenu();
    apptray.createTray();
}
// 设置菜单栏
function createMenu() {
    // darwin表示macOS，针对macOS的设置
    if (process.platform === "darwin") {
        const template = [
            {
                label: "App Demo",
                submenu: [
                    {
                        role: "about",
                    },
                    {
                        role: "quit",
                    },
                ],
            },
        ];
        let menu = Menu.buildFromTemplate(template);
        Menu.setApplicationMenu(menu);
    } else {
        // windows及linux系统
        Menu.setApplicationMenu(null);
    }
}
// Quit when all windows are closed.
app.on("window-all-closed", () => {
    // On macOS it is common for applications and their menu bar
    // to stay active until the user quits explicitly with Cmd + Q
    if (process.platform !== "darwin") {
        app.quit();
    }
});

app.on("activate", () => {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (mainWinow === null) {
        createWindow();
    }
});

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on("ready", async () => {
    if (isDevelopment && !process.env.IS_TEST) {
        // Install Vue Devtools
        try {
            await installExtension(VUEJS_DEVTOOLS);
        } catch (e) {
            console.error("Vue Devtools failed to install:", e.toString());
        }
    }
    // 在开发环境和生产环境均可通过快捷键打开devTools
    globalShortcut.register("CommandOrControl+F12", function () {
        mainWinow.webContents.openDevTools({ mode: "detach" });
    });
    createWindow();
});

// Exit cleanly on request from parent process in development mode.
if (isDevelopment) {
    if (process.platform === "win32") {
        process.on("message", (data) => {
            if (data === "graceful-exit") {
                app.quit();
            }
        });
    } else {
        process.on("SIGTERM", () => {
            app.quit();
        });
    }
}

ipcMain.on("min", (e) => {
    mainWinow.minimize();
});
ipcMain.on("max", (e) => {
    if (mainWinow.isMaximized()) {
        mainWinow.unmaximize();
    } else {
        mainWinow.maximize();
    }
});
ipcMain.on("close", (e) => {
    // mainWinow.minimize();
    // mainWinow.hide();
    mainWinow = null;
    app.quit();
});
ipcMain.on("routerIn", (e, name) => {
    mainWinow.webContents.send("setSelectItem", { data: name });
});
/**
 * 托盘图标事件
 */
let flashTrayTimer = null;
let trayIco1 = `${__static}/favicon-new.ico`;
let trayIco2 = `${__static}/empty.ico`;
let tray;
let apptray = {
    // 创建托盘图标
    createTray() {
        tray = new Tray(trayIco1);
        const menu = Menu.buildFromTemplate([
            // {
            //     label: '打开主界面',
            //     // icon: `${__static}/tray-ico1.png`,
            //     click: () => {
            //         if (mainWinow.isMinimized()) mainWinow.restore()
            //         mainWinow.show()
            //         mainWinow.focus()
            //         mainWinow.webContents.send('setSelectItem', { data: '', needClick: true })
            //         this.flashTray(false)
            //     }
            // },
            // {
            //     label: "zip压缩",
            //     click: () => {
            //         if (mainWinow.isMinimized()) mainWinow.restore();
            //         mainWinow.show();
            //         mainWinow.focus();
            //         this.flashTray(false);
            //         mainWinow.webContents.send("setSelectItem", { data: "about", needClick: true });
            //     },
            // },
            {
                label: "退出",
                click: () => {
                    if (process.platform !== "darwin") {
                        // mainWinow.show();
                        // 清空登录信息
                        mainWinow.webContents.send("clearLoggedInfo");
                        mainWinow = null;
                        app.quit();
                    }
                },
            },
        ]);
        tray.setContextMenu(menu);
        tray.setToolTip("兆日前端挡板");
        // 托盘点击事件
        tray.on("click", () => {
            if (mainWinow.isMinimized()) mainWinow.restore();
            mainWinow.show();
            mainWinow.focus();
            this.flashTray(false);
        });
    },
    // 托盘图标闪烁
    flashTray(bool) {
        let hasIco = false;
        if (bool) {
            if (flashTrayTimer) return;
            flashTrayTimer = setInterval(() => {
                tray.setImage(hasIco ? trayIco1 : trayIco2);
                hasIco = !hasIco;
            }, 500);
        } else {
            if (flashTrayTimer) {
                clearInterval(flashTrayTimer);
                flashTrayTimer = null;
            }
            tray.setImage(trayIco1);
        }
    },
    // 销毁托盘图标
    destroyTray() {
        this.flashTray(false);
        tray.destroy();
        tray = null;
    },
};

ipcMain.on("ondragstart", (event, filePath) => {
    event.sender.startDrag({
        file: filePath,
        icon: `${__static}/favicon.ico`,
    });
});
//判断文件夹是否存在操作
function fsExistsSync(myDir) {
    try {
        fs.accessSync(myDir);
        return true;
    } catch (e) {
        return false;
    }
}
//递归删除文件操作
function removeFiles(path) {
    var files = [];
    if (fs.existsSync(path)) {
        files = fs.readdirSync(path);
        files.forEach(function (file, index) {
            var curPath = path + "/" + file;
            if (fs.statSync(curPath).isDirectory()) {
                // recurse
                removeFiles(curPath);
            } else {
                // delete file
                fs.unlinkSync(curPath);
            }
        });
        fs.rmdirSync(path);
    }
}
//判断文件夹存在
function isExisted(src, dest) {
    if (!fsExistsSync(dest)) {
        CopyDirectory(src, dest);
    } else {
        dialog
            .showMessageBox({
                type: "warning",
                title: "重要提示",
                message: "当前目录下，已存在同名文件夹。",
                detail: "确认即覆盖当前文件夹，取消即不做操作。",
                buttons: ["确认", "取消"],
                noLink: true,
                cancelId: 1,
            })
            .then((res) => {
                if (res.response == 0) {
                    removeFiles(dest);
                    setTimeout(() => {
                        CopyDirectory(src, dest);
                    }, 2000);
                } else if (res.response == 1) {
                    return;
                }
            });
    }
}
//拷贝操作
function CopyDirectory(src, dest) {
    let _this = this;
    fs.mkdirSync(dest);
    // 拷贝新的内容进去
    var dirs = fs.readdirSync(src);
    dirs.forEach(function (item) {
        var item_path = path.join(src, item);
        var temp = fs.statSync(item_path);
        if (temp.isFile()) {
            // 是文件
            fs.copyFileSync(item_path, path.join(dest, item));
        } else if (temp.isDirectory()) {
            // 是目录
            CopyDirectory(item_path, path.join(dest, item));
        }
    });
}

ipcMain.on("downLoad", (event, url) => {
    isExisted(url.linePath, url.savePath);
});

ipcMain.on("doTransData", (event, data) => {
    console.log("data", data);
    let encoding = "GBK";
    let transData = data.data;
    let id = data.id;
    transData = iconv.decode(transData, encoding);
    event.sender.send("transData", { id, data: transData });
});

ipcMain.on("editDir", (event, data) => {
    let { product } = data;
    let result = {
        type: true,
        msg: "获取成功",
        data: {},
    };
    if (product === projectStatus.bizmate) {
        return editDirFun(data)
            .then((res) => {
                if (res) {
                    result.data = res.data;
                    result.msg = transMsg(res, true);
                    event.sender.send("sendPlugin", result);
                }
            })
            .catch((e) => {
                result.type = false;
                result.msg = transMsg(e, false);
                event.sender.send("sendPlugin", result);
            });
    } else if (product === projectStatus.yqt) {
        return oldEditDirFun(data)
            .then((res) => {
                if (res) {
                    console.log("res", res);
                    result.data = res.data;
                    result.msg = transMsg(res, true);
                    event.sender.send("sendPlugin", result);
                }
            })
            .catch((e) => {
                console.log("e", e);
                result.type = false;
                result.msg = transMsg(e, false);
                event.sender.send("sendPlugin", result);
            });
    }
});

ipcMain.on("getCurIp", (event, data) => {
    let nowIp = data.ip;
    let ip = internalIp.v4.sync() || `localhost`;
    if (ip == nowIp) return false;
    event.sender.send("sendCurIp", { ip });
});

ipcMain.on("getPlatform", (event, data) => {
    let platform = process.platform
    event.sender.send("sendPlatform", { platform });
});

ipcMain.on("openChrome", (event, data) => {
    let { url } = data;
    open(url, "chrome");
});

function transMsg(e, type) {
    let codeMsg = {
        101: "文件地址错误",
        102: "文件存在插件内容",
        200: "插件写入成功",
    };
    return `获取${type ? "成功" : "失败"}： -- ${e.name} ${codeMsg[e.code]} -- ${e.error}`;
}
