import R from 'ramda'

const ClueList = ({clues, title}) => {
  return (
    <div style={{minWidth: 200, margin: '0 5px'}}>
      <h4 style={{margin: '5px 0'}}>{title}</h4>
      <div style={{fontSize: '0.95em', margin: '2px 0', maxHeight: 800}}>
        {R.keys(clues).map(n => (
          <div key={n}>
            <div style={{fontFamily: 'Inconsolata', display: 'inline-block', marginRight: 5, width: 20, textAlign: 'right'}}>
              {n}
            </div>
            <span style={{fontFamily: 'Source Sans Pro'}}>{clues[n]}</span>
          </div>
        ))}
      </div>
    </div>
  )
}

export default ClueList
