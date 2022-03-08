<template>
    <div class="titleBtn" :style="style" @click="click" :title="title">
        <img :src="content" />
    </div>
</template>

<script>
const {ipcRenderer: ipc} = window.require('electron');
const content = {
    min: require('@/assets/icon_common_minimum_nor.svg'),
    max: require('@/assets/icon_common_max_nor.svg'),
    close: require('@/assets/icon_common_gclose_nor.svg')
}
const title = { min: '最小化', max: '最大化', close: '关闭' }
const style = {
    min: {
        right: '100px'
    },
    max: {
        right: '60px'
    },
    close: {
        right: '20px'
    }
}
import './TitleBtn.less'
export default {
    name: 'titleBtn',
    props: {
        type: {
            type: String
        }
    },
    computed: {
        style() {
            return style[this.type]
        },
        content() {
            return content[this.type]
        },
        title() {
            return title[this.type]
        }
    },
    data() {
        return {}
    },
    created() {},
    methods: {
        click() {
            ipc.send(this.type)
        }
    }
}
</script>
<style lang="less">
.titleBtn {
    user-select: none;
    position: absolute;
    width: 20px;
    height: 20px;
    top: 0;
    bottom: 0;
    margin: auto 0;
    -webkit-app-region: no-drag;
    overflow: hidden;
    cursor: pointer;
    img {
        width: 100%;
        color: #fff;
        filter: drop-shadow(#fff 80px 0);
        transform: translateX(-80px);
    }
}
</style>