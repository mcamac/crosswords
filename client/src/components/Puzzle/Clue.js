const Clue = ({n, clue, fixed, style}) =>
  <div key={n} style={{display: 'flex', flexFlow: 'row', ...(style || {})}}>
    <div style={{fontFamily: 'Source Serif Pro', fontWeight: 600, display: 'inline-block', marginRight: 5, flexBasis: fixed ? 20 : null, textAlign: 'right'}}>
      {n}
    </div>
    <div style={{fontFamily: 'Source Serif Pro', flex: '1 1'}}>{clue}</div>
  </div>

export default Clue
