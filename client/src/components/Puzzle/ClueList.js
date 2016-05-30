import R from 'ramda'
import Clue from './Clue'

const headingStyle = marginTop => ({
  fontWeight: 600, margin: `${marginTop} 10px 5px`, textAlign: 'center'
})

const getStyle = (n, dir, clue) => {
  if (clue.active.n == n && clue.active.direction === dir) {
    return {background: 'rgba(0, 0, 255, 0.18)'}
  }
  if (clue.inactive.n == n && clue.inactive.direction === dir) {
    return {background: 'rgba(0, 0, 0, 0.18)'}
  }
  return {}
}

const ClueList = ({clues, clue}) => {
  return (
    <div style={{width: 250, margin: '0 5px', fontSize: '1em'}}>
      <h4 style={{...headingStyle(0)}}>ACROSS</h4>
      {R.keys(clues.across).map(n => (
        <Clue key={n} fixed={20} n={n} clue={clues.across[n]} style={getStyle(n, 'A', clue)} />
      ))}
      <h4 style={{...headingStyle('15px')}}>DOWN</h4>
      {R.keys(clues.down).map(n => (
        <Clue key={n} fixed={20} n={n} clue={clues.down[n]} style={getStyle(n, 'D', clue)} />
      ))}
    </div>
  )
}

export default ClueList
