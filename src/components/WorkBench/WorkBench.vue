<template>
    <div class="content">
        <div class="left_chat_list">
            <LeftMenu></LeftMenu>
        </div>
        <div class="right_chat_content">
            <keep-alive>
                <router-view></router-view>
            </keep-alive>
        </div>
    </div>
</template>

<script>
import LeftMenu from '@/components/LeftMenu/LeftMenu.vue'
// import RightContent from '@/components/RightContent/RightContent.vue'
export default {
    name: 'workBench',
    components: {
        LeftMenu,
        // RightContent
    },
    data() {
        return {}
    }
}
</script>

<style lang="less">
.content {
    width: 100%;
    height: calc(~'100% - 52px');
    display: flex;
    .left_chat_list {
        width: 240px;
        height: 100%;
        border-right: 1px solid #e5e5e5;
    }
    .right_chat_content {
        height: 100%;
        flex: 1;
        background: #f2f3f5;
        overflow: hidden;
        position: relative;
    }
}
</style>