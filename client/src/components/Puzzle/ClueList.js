import R from 'ramda'
import Clue from './Clue'

const headingStyle = marginTop => ({
  fontWeight: 600, margin: `${marginTop} 10px 5px`, textAlign: 'center'
})

const ClueList = ({clues}) => {
  return (
    <div style={{width: 250, margin: '0 5px', fontSize: '1em'}}>
      <h4 style={{...headingStyle(0)}}>ACROSS</h4>
      {R.keys(clues.across).map(n => (
        <Clue key={n} fixed n={n} clue={clues.across[n]} />
      ))}
      <h4 style={{...headingStyle('15px')}}>DOWN</h4>
      {R.keys(clues.down).map(n => (
        <Clue key={n} fixed n={n} clue={clues.down[n]} />
      ))}
    </div>
  )
}

export default ClueList
