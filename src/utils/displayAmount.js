export default function (value) {
  if (value === 0) {
    return '-'
  }
  const sign = value > 0 ? '+' : '-'
  value = Math.abs(Math.round(value))
  if (value >= 1000000) {
    return sign + Math.round(value/100000) / 10 + 'm'
  } else if (value > 1000) {
    return sign + Math.round(value/100) / 10 + 'k'
  } else {
    return sign + value
  }
}
