import Foundation

// Struct pembantu untuk menyimpan state
struct State: Hashable {
    let currentVert: Int // indeks vertex saat ini
    let remainderVert: Set<Int> // set vertex yang belum dikunjungi
}

// Fungsi solver untuk menyelesaikan masalah Traveling Salesman Problem (TSP)
func solver(graph: [[Int]]) -> (cost: Int, path: [Int])? {
    let n = graph.count // jumlah vertex pada graph

    if n <= 1 { 
        return (0, [])
    }

    var minimumCosts = [State: Int]() // menyimpan biaya minimum untuk setiap state
    var pathStates = [State: Int]() // menyimpan jalur optimal untuk setiap state

    // Fungsi pembantu rekursif untuk menemukan biaya minimum
    // General idea mengikuti f(1, V - {1}) = min(c(1, v) + f(v, V - {1, v}))
    func findMinimum(currentVert: Int, remainderVert: Set<Int>) -> Int {
        if remainderVert.isEmpty {
            return graph[currentVert][0]
        }

        let thisState = State(currentVert: currentVert, remainderVert: remainderVert)

        // Cek apakah state ini sudah pernah dihitung, jika ya, kembalikan biaya yang sudah disimpan
        if let savedCost = minimumCosts[thisState] {
            return savedCost
        }

        // Variabel untuk menyimpan biaya minimum dan vertex berikutnya
        var min = Int.max
        var bestNext = -9999

        // Iterasi melalui vertex yang tersisa untuk menemukan jalur optimal
        for nextVert in remainderVert {
            var remaining = remainderVert
            remaining.remove(nextVert) // menghapus vertex yang sudah dikunjungi

            // Hitung biaya untuk melanjutkan ke vertex berikutnya
            // f(1, V - {1}) = c(1, v) + f(v, V - {v})
            let cost = graph[currentVert][nextVert] + findMinimum(currentVert: nextVert, remainderVert: remaining)

            if cost < min {
                min = cost
                bestNext = nextVert
            }
        }

        // Simpan biaya minimum dan jalur optimal untuk state ini
        minimumCosts[thisState] = min
        pathStates[thisState] = bestNext

        return min
    }

    // Set vertext yang belum dikunjungi, berisi vertex selain vertex awal
    let otherVertices = Set(1..<n)

    // Minimum cost
    let totMinCost = findMinimum(currentVert: 0, remainderVert: otherVertices)

    var path = [0] // Mulai dari vertex 0
    var current = 0 // Vertex saat ini
    var remainder = otherVertices // Set berisi otherVertices (dibuat var agar bisa diubah)

    // Membangun jalur berdasarkan state yang telah disimpan
    while !remainder.isEmpty {
        let state = State(currentVert: current, remainderVert: remainder)
        // Cek apakah ada jalur yang ditemukan untuk state ini
        guard let nextVert = pathStates[state] else {
            return nil
        }

        path.append(nextVert) // Tambahkan vertex berikutnya ke jalur
        remainder.remove(nextVert) // Hapus vertex yang sudah dikunjungi dari set
        current = nextVert // Lanjut ke vertex berikutnya
    }

    path.append(0) // Kembali ke vertex awal (0)

    return (cost: totMinCost, path: path)
}

// Contoh penggunaan (dari PPT)
let costMatrix = [
    [0, 10, 15, 20],
    [5,  0,  9, 10],
    [6, 13,  0, 12],
    [8,  8,  9,  0]
]

print("Graf dalam representasi matriks adjacency: ")

for i in 0..<costMatrix.count {
    for j in 0..<costMatrix[i].count {
        print(costMatrix[i][j], terminator: " ")
    }
    print()
}

if let result = solver(graph: costMatrix) {
    print("Jalur optimal: \(result.path.map { $0 + 1 }.map(String.init).joined(separator: " -> "))")
    print("Biaya: \(result.cost)")
} else {
    print("Tidak ada solusi.")
}

