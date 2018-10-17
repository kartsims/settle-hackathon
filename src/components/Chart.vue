<script>
import { Bar } from 'vue-chartjs'

export default {
  extends: Bar,
  props: ['labels', 'inValues', 'outValues'],
  mounted () {
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
    })
  }
}
</script>
