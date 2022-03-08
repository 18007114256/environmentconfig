const fs = window.require("fs");
const path = window.require("path");

let realPath = getRealPath();

function getRealPath() {
    let num = __dirname.indexOf("node_modules");
    let devSrc = __dirname.slice(0, num - 1);
    let DevSinosun = path.join(devSrc, "./public/scpmock/config.js");
    let realPath =
        process.env.NODE_ENV === "development"
            ? DevSinosun
            : path.join(__dirname, "./scpmock/config.js");
    return realPath;
}

function getBaseData() {
    let configData = fs.readFileSync(realPath).toString().split("\n");
    let baseData = [[], [], [], [], []];
    let portStr = "";
    let projectStr = "";
    let staticUrlStr = "";
    let siteUrlStr = "";
    let index = 0;
    configData.forEach((item) => {
        if (item.indexOf("port:") != -1) {
            portStr += item;
            index++;
        } else if (item.indexOf("staticUrl:") != -1) {
            staticUrlStr += item;
            index++;
        } else if (item.indexOf("siteUrl:") != -1) {
            siteUrlStr += item;
            index++;
        } else if (index == 2 || item.indexOf("projects:") != -1) {
            projectStr += item + "\n";
            index == 1 && index++;
            index == 2 && baseData[index].push(item);
        } else {
            baseData[index].push(item);
        }
    });
    projectStr = projectStr.split("\n");
    projectStr.pop();
    projectStr.pop();
    projectStr = projectStr.join("\n");
    baseData[2] = [baseData[2][baseData[2].length - 1]];
    return { baseData, portStr, projectStr, staticUrlStr, siteUrlStr };
}

function editPort(portStr, newPort) {
    let port = portStr.split(": ")[1].split(",")[0];
    if (newPort == undefined) return port;
    portStr = portStr.replace(port, newPort);
    return portStr;
}

function editSiteUrl(siteUrlStr, newSiteUrl) {
    let siteUrl = siteUrlStr.split("//")[1].split('"')[0];
    if (newSiteUrl == undefined) return siteUrl;
    siteUrlStr = siteUrlStr.replace(siteUrl, newSiteUrl);
    return siteUrlStr;
}

function editStaticUrlStr(staticUrlStr, newStaticUrlStr) {
    let staticUrl = staticUrlStr.split("//")[1].split('"')[0];
    staticUrlStr = staticUrlStr.replace(staticUrl, newStaticUrlStr);
    return staticUrlStr;
}

function editProject(projectStr, newArr) {
    let resStr = "";
    let project = {
        start: "    projects: {\n",
        end: "    },",
    };
    projectStr = projectStr
        .split("\n")
        .filter((item) => !item.includes("//"))
        .join("\n");
    let res = projectStr.match(/"(.+)"/g);
    res = (res || []).map((item) => item.replace('"', "").replace('"', ""));
    if (newArr == undefined) return res;

    resStr += project.start;
    newArr.forEach((item, index) => {
        resStr += `        p${index + 1}: "${item}",\n`;
    });
    resStr += project.end;
    console.log(resStr);
    return resStr;
}

function reduceFun(pre, cur) {
    return pre + cur + "\n";
}

function assemblyData(options) {
    let { baseData, portStr, projectStr, staticUrlStr, siteUrlStr } = options;
    let resData = "";
    baseData.forEach((item, index) => {
        if (index == 0) {
            resData += item.reduce(reduceFun, "");
        } else if (index == 1) {
            resData += portStr + "\n";
            resData += item.reduce(reduceFun, "");
        } else if (index == 2) {
            resData += projectStr + "\n";
            resData += item.reduce(reduceFun, "");
        } else if (index == 3) {
            resData += siteUrlStr + "\n";
            resData += item.reduce(reduceFun, "");
        } else if (index == 4) {
            resData += staticUrlStr + "\n";
            resData += item.reduce(reduceFun, "");
        }
    });
    return resData;
}

function writeConfig(data) {
    try {
        fs.writeFileSync(realPath, data.substring(0, data.lastIndexOf("\n")), "utf-8");
        return "修改成功";
    } catch (error) {
        return `修改失败:${error}`;
    }
}

export function editConfig(options) {
    if (!options) return getBaseData();
    let { port, project, ip } = options;
    let { baseData, portStr, projectStr, staticUrlStr, siteUrlStr } = getBaseData();
    portStr = editPort(portStr, port);
    siteUrlStr = editSiteUrl(siteUrlStr, ip);
    staticUrlStr = editStaticUrlStr(staticUrlStr, ip);
    projectStr = editProject(projectStr, project);
    let resData = assemblyData({ baseData, portStr, projectStr, staticUrlStr, siteUrlStr });
    let endType = writeConfig(resData);
    return endType;
}

export function getConfig() {
    let { portStr, projectStr, siteUrlStr } = editConfig();
    portStr = editPort(portStr);
    siteUrlStr = editSiteUrl(siteUrlStr);
    projectStr = editProject(projectStr);
    return { port: portStr, project: projectStr, ip: siteUrlStr };
}
