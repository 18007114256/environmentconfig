
/**
 * 支持的附件类型
 */
const FjType = ['IMG', 'Word', 'Excel', 'PPT', 'PDF', 'TXT', 'COMPRESS', 'MUSIC', 'VIDEO', 'CODE']
const FjMimeType = [
    ['bmp', 'jpg', 'jpeg', 'png', 'gif', 'ico'], //IMG
    ['doc', 'docx', 'dot', 'dotx', 'docm'], //Word
    ['xlsx', 'xls', 'xlsm'], //Excel
    ['pptx', 'pptm', 'ppt'], //PPT
    ['pdf'], //PDF
    ['txt'], //TXT
    ['rar', 'zip', 'gz', '7z'], //COMPRESS
    ['mp3', 'rm', 'amr', 'wav', 'ogg', 'midi', '3gpp'], //MUSIC
    ['avi', 'flv', 'wmv', 'mp4', 'rmvb', 'mov'],
    ['js', 'html', 'vue', 'json']
] //VIDEO

const { ipcRenderer: ipc } = window.require('electron')
const fs = window.require('fs')
const path = window.require('path')
const dialog = window.require('electron').remote.dialog
// var ProSinosun = path.join(__dirname, './sinosun-ui/index.html')
var ProClient = path.join(__dirname, './SWP-Client')
// var DevSinosun = './public/sinosun-ui/index.html' //本地路径
// process.env.NODE_ENV === 'development' ? DevSinosun : ProSinosun,
var DevClient = './public/SWP-Client' //本地路径

var Handler = function () {
}
Handler.prototype = {
    /**
 * 文件类型判断
 * @param {Object} fileName  原始名称
 * */
    fileExtensionCheck(fileName) {
        var extension = ''
        var arr = fileName.split('.')
        var houzui = arr[arr.length - 1].toLowerCase()
        for (var i = 0; i < FjMimeType.length; i++) {
            // 循环查找
            if (FjMimeType[i].indexOf(houzui) > -1) {
                extension = FjType[i]
                break
            } else {
                //如果不在支持的附件列表则返回后缀
                if (i == FjMimeType.length - 1) {
                    extension = houzui
                    break
                }
            }
        }
        return extension
    },
    downLoadFunction(data) {
        const { title, name, type, loadPath } = data
        return new Promise((resolve, reject) => {
            dialog
                .showSaveDialog({
                    title: title,
                    defaultPath: name,
                })
                .then((res) => {
                    console.log(res)
                    if (!res.canceled) {
                        if (type == 1) {
                            let code = document.getElementsByTagName('code')[0]
                            fs.writeFileSync(res.filePath, code.innerHTML)
                            resolve(true)
                        } else if (type == 2) {
                            let data = fs.readFileSync(loadPath, 'utf-8')
                            fs.writeFileSync(res.filePath, data)
                            console.log('读取文件成功,内容是' + data)
                            resolve(true)
                        } else if (type == 3) {
                            let url = {}
                            url['linePath'] = process.env.NODE_ENV === 'development' ? DevClient : ProClient
                            url['savePath'] = res.filePath
                            ipc.send('downLoad', url)
                            resolve(true)
                        } else if (type == 4) {
                            resolve(res)
                        }
                    } else {
                        reject(res)
                    }
                })
                .catch((req) => {
                    console.log(req)
                    reject(req)
                })
        })
    },
    showTip(data) {
        const { type, title, message } = data
        return new Promise((resolve) => {
            dialog
                .showMessageBox({
                    type: type,
                    title: title,
                    message: message,
                })
                .then((res) => {
                    console.log(res)
                    resolve(res)
                })
        })
    }
}

export default new Handler();
