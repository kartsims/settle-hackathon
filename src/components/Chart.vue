<script>
import { Bar } from 'vue-chartjs'
import displayAmount from '@/utils/displayAmount'

export default {
  extends: Bar,
  props: ['labels', 'inValues', 'outValues'],
  watch: {
    labels: {
      deep: true,
      handler: function () { this.doRender() }
    },
    inValues: {
      deep: true,
      handler: function () { this.doRender() }
    },
    outValues: {
      deep: true,
      handler: function () { this.doRender() }
    },
  },
  mounted () {
    this.doRender()
  },
  methods: {
    doRender () {
      this.renderChart({
        labels: this.labels,
        datasets: [
          {
            label: 'IN',
            backgroundColor: 'rgb(23, 94, 23)',
            data: this.inValues,
          },
          {
            label: 'OUT',
            backgroundColor: 'rgb(139, 13, 13)',
            data: this.outValues,
          },
        ]
      }, {
        aspectRatio: .2,
        legend: {
          display: false
        },
        scales: {
          xAxes: [{
            stacked: true,
            ticks: {
              beginAtZero: true,
              callback: function(value, index, values) {
                return null
              }
            }
          }],
          yAxes: [{
            ticks: {
              callback: function(value, index, values) {
                return displayAmount(value)
              }
            }
          }],
        },
        tooltips: {
          callbacks: {
            label: function(tooltipItem, data) {
              return displayAmount(tooltipItem.yLabel)
            }
          }
        },
      })
    },
  }
}
</script>
