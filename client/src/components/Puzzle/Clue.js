const Clue = ({n, clue, fixed}) =>
  <div key={n}>
    <div style={{fontFamily: 'Source Serif Pro', fontWeight: 600, display: 'inline-block', marginRight: 5, width: fixed ? 20 : null, textAlign: 'right'}}>
      {n}
    </div>
    <span style={{fontFamily: 'Source Serif Pro'}}>{clue}</span>
  </div>

export default Clue
