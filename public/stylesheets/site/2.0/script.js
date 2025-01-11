import fs from 'fs'
import path from 'path'

fs.readdir('./', (err, files) => {
    if (err) {
        console.error('Error reading directory:', err);
        return
    }
    const cssFiles = files.filter(file => path.extname(file) === '.css')
    // const file = cssFiles[0]
    cssFiles.forEach(file => {
        fs.readFile(file, 'utf8', (err, data) => {
            if (err) {
                console.error(`Error reading file ${file}:`, err)
                return
            }
            const lines = data.split('\n')
            const newFile = []
            lines.forEach((line) => {
                const comments = []
                const matches = Array.from(line.matchAll((()=>{
                    if (/font/.test(line)) return /((\d+\.)?\d+)em|((\d+\.)?\d+)%|\/\b((\d+\.)?\d+)\b/g
                    if (/line-height/.test(line)) return /(ъ)(ъ)(ъ)(ъ)|\b((\d+\.)?\d+)\b/g
                    return  /((\d+\.)?\d+)em/g
                })()))
                if (!matches.length) {
                    newFile.push(line)
                    return
                }
                matches.forEach(match => {
                    if (match[1]) comments.push(Math.round(Number(match[1]) * 14 * 100) / 100)
                    if (match[3]) comments.push(Math.round(Number(match[3]) * 14) / 100)
                    if (match[5]) comments.push('_')
                })
                newFile.push(`${line} /* OLD ${comments.join('px, ')}px -> NEW  */`)
            })
            fs.writeFile(`./temp/${file}`, newFile.join('\n'), (err) => {
                if (err) throw err;
                console.log(`./temp/${file} success`);
            })
        })
    })
})