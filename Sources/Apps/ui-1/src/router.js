import Vue from 'vue'
import Router from 'vue-router'

import About from './views/About.vue'
import Accounts from './views/Accounts.vue'
import AccountsAdd from './views/AccountsAdd.vue'
import Charts from './views/Charts.vue'
import Tx from './views/Tx.vue'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      component: Tx
    },
    {
      path: '/about',
      component: About
    },
    {
      path: '/accounts',
      component: Accounts
    },
    {
      path: '/charts',
      component: Charts
    },
    {
      path: '/add',
      component: AccountsAdd
    },
  ]
})
