import R from 'ramda'
import {pure} from 'recompose'

let sqi = R.xprod(R.range(0, 15), R.range(0, 15))

const StaticGrid = ({squareSize, height, rows, puzzle}) => {
  console.log('render StaticGrid')
  const numbered = sqi.filter(([r, c]) => (
    puzzle[r][c] !== '_' && (r === 0 || c === 0 || puzzle[r - 1][c] === '_' || puzzle[r][c - 1] === '_')
  ))
  return (
    <g>
      <g>
        {R.times(i => (
          <line key={`r${i}`} stroke='#bbb' x1={i * squareSize + 0.5} x2={i * squareSize + 0.5} y1={0} y2={height}/>
        ), rows + 1)}
        {R.times(i => (
          <line key={`c${i}`} stroke='#bbb' y1={i * squareSize + 0.5} y2={i * squareSize + 0.5} x1={0} x2={height}/>
        ), rows + 1)}
      </g>
      <g>
        {sqi.filter(([r, c]) => puzzle[r][c] === '_').map(([r, c]) => (
          <rect
            key={`${r}_${c}`}
            x={c * squareSize}
            y={r * squareSize}
            width={squareSize}
            height={squareSize}
            fill='black'/>
        ))}
      </g>
      <g>
        {numbered.map(([r, c], i) => (
          <text
            key={`${r}_${c}`}
            style={{fontSize: '10px', fontFamily: 'Inconsolata'}}
            x={c * squareSize + 2}
            y={(r + 0.1) * squareSize + 8}
            textAnchor='start'
          >
            {i + 1}
          </text>
        ))}
      </g>
    </g>
  )
}
export default pure(StaticGrid)
