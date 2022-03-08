<template>
    <div class="box">
        <div
            class="item"
            v-for="(item, index) in dataList"
            :key="index"
            @click="click(item)"
            :class="{ selected: selectedItem.title == item.title }"
        >
            {{ item.title }}
        </div>
    </div>
</template>

<script>
const { ipcRenderer: ipc } = window.require('electron')
import './LeftMenu.less'
export default {
    name: 'leftMenu',
    data() {
        return {
            dataList: [
                // {
                //     title: '下载页面',
                //     path: '',
                // },
                // {
                //     title: '压缩',
                //     path: 'about',
                // },
                // {
                //     title: '代码展示',
                //     path: 'attendance',
                // },
                // {
                //     title: 'json2csv',
                //     path: 'money',
                // },
                // {
                //     title: '组件库',
                //     path: 'sinosun',
                // },
                {
                    title: '数据管理',
                    path: 'pluginScpmock',
                },
                {
                    title: '插件管理',
                    path: 'pluginH5',
                },
                // {
                //     title: '插件管理',
                //     path: 'pluginHome',
                // },
                // {
                //     title: '测试',
                //     path: 'test',
                // },
                // {
                //     title: '压缩',
                //     path: 'tar',
                // },
                // {
                //     title: '文档',
                //     path: 'library',
                // },
            ],
            selectedItem: {
                title: '审批',
                path: '',
            },
        }
    },
    mounted() {
        let _this = this
        ipc.on('setSelectItem', (e, arg) => {
            _this.dataList.forEach((item) => {
                if (item.path == arg.data) {
                    _this.selectedItem = item
                    if (arg.needClick) {
                        _this.click(item)
                    }
                }
            })
        })
    },
    methods: {
        click(item) {
            this.selectedItem = item
            this.$router.push(`/${item.path}`)
        },
    },
}
</script>

<style lang="less">
.box {
    user-select: none;
    padding: 0 20px;
    overflow-y: scroll;
    height: 100%;
    .item {
        width: 100%;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-top: 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
        cursor: pointer;
    }
    .item:hover {
        color: #fff;
        background: cornflowerblue;
        border-color: #fff;
    }
    .selected {
        color: #fff;
        background: rgb(47, 112, 233);
        border-color: #fff;
    }
}
</style>