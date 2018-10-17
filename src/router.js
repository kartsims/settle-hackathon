import Vue from 'vue'
import Router from 'vue-router'

import About from './views/About.vue'
import Home from './views/Home.vue'
import WorkMode from './views/WorkMode.vue'
import WorkAccounts from './views/Work/Accounts.vue'
import WorkAdd from './views/Work/Add.vue'
import WorkCharts from './views/Work/Charts.vue'
import WorkTx from './views/Work/Tx.vue'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      component: Home
    },
    {
      path: '/work',
      component: WorkMode,
      children: [
        {
          path: '',
          component: WorkTx
        },
        {
          path: 'about',
          component: About
        },
        {
          path: 'accounts',
          component: WorkAccounts
        },
        {
          path: 'charts',
          component: WorkCharts
        },
        {
          path: 'add',
          component: WorkAdd
        }
      ]
    }
  ]
})
