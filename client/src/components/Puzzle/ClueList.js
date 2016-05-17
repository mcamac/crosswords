import R from 'ramda'
import Clue from './Clue'

const ClueList = ({clues, title}) => {
  return (
    <div style={{minWidth: 200, margin: '0 8px', padding: '0 5px'}}>
      <h4 style={{fontWeight: 600, margin: '5px 5px'}}>{title}</h4>
      <div style={{fontSize: '0.95em', margin: '2px 0', maxHeight: 800}}>
        {R.keys(clues).map(n => (
          <Clue key={n} fixed n={n} clue={clues[n]} />
        ))}
      </div>
    </div>
  )
}

export default ClueList
