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
                const matches = Array.from(line.matchAll(/font/.test(line) ? /((\d+\.)?\d+)em|((\d+\.)?\d+)%/g : /((\d+\.)?\d+)em/g))
                if (!matches.length) {
                    newFile.push(line)
                    return
                }
                matches.forEach(match => {
                    const px = Math.round((match[3] ? Number(match[3]) / 100 * 14 : Number(match[1]) * 14)*100)/100
                    comments.push(`${px}px`)
                })
                newFile.push(`${line} /* px values probably: ${comments.join(', ')} */`)
            })
            fs.writeFile(`./temp/${file}`, newFile.join('\n'), (err) => {
                if (err) throw err;
                console.log(`./temp/${file} success`);
            })
        })
    })
})