const Clue = ({n, clue, fixed, style, direction}) =>
  <div key={n} style={{fontFamily: 'Source Serif Pro', display: 'flex', breakInside: 'avoid', flexFlow: 'row', ...(style || {})}}>
    <div style={{fontWeight: 600, display: 'inline-block', marginRight: 5, flexBasis: fixed ? fixed : null,
      textAlign: direction ? 'left' : 'right'}}>
      {direction &&
        <span style={{marginRight: 5}}>{direction === 'A' ? '▶' : '▼'}</span>
      }
      {n}
    </div>
    <div style={{flex: '1 1'}}>{clue}</div>
  </div>

export default Clue
