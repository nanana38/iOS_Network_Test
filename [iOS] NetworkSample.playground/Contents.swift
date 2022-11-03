import UIKit

struct MovieData: Codable {
    let boxOfficeResult: BoxOfficeResult
}

struct BoxOfficeResult: Codable {
    let dailyBoxOfficeList: [DailyBoxOfficeList]
}

struct DailyBoxOfficeList: Codable {
    let rank: String
    let movieNm: String
    let audiCnt: String
    let audiAcc: String
    let openDt: String
}

struct Movie {
    static var movieId: Int = 0
    let movieName: String
    let rank: Int
    let openDate: String
    let todayAudience: Int
    let totalAudience: Int
    
    init(movieNm: String, rank: String, openDate: String, audiCnt: String, accAudi: String) {
        self.movieName = movieNm
        self.rank = Int(rank)!
        self.openDate = openDate
        self.todayAudience = Int(audiCnt)!
        self.totalAudience = Int(accAudi)!
        Movie.movieId += 1
    }
}

struct MovieDataManager {
    
    let movieURL = "http://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?"
    
    let myKey = "c633109266ca03733f499e0610152ad2"
    
    func fetchMovie(date: String, completion: @escaping ([Movie]?) -> Void) {
        let urlString = "\(movieURL)&key=\(myKey)&targetDt=\(date)"
        performRequest(with: urlString) { movies in
            completion(movies)
        }
    }
    
    func performRequest(with urlString: String, completion: @escaping ([Movie]?) -> Void) {
        print(#function)
        
        guard let url = URL(string: urlString) else { return }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let safeData = data else {
                completion(nil)
                return
            }
            
            if let movies = self.parseJSON(safeData) {
                completion(movies)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func parseJSON(_ movieData: Data) -> [Movie]? {
        print(#function)
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(MovieData.self, from: movieData)
            
            let dailyLists = decodedData.boxOfficeResult.dailyBoxOfficeList
            
            let myMovielists = dailyLists.map {
                Movie(movieNm: $0.movieNm, rank: $0.rank, openDate: $0.openDt, audiCnt: $0.audiCnt, accAudi: $0.audiAcc)
            }
            return myMovielists
            
        } catch {
            print("파싱 실패")
            return nil
        }
    }
}

var downloadedMovies = [Movie]()

let movieManager = MovieDataManager()

movieManager.fetchMovie(date: "20210201") { (movies) in
    
    if let movies = movies {
        
        downloadedMovies = movies
        dump(downloadedMovies)
        
        print("전체 영화 갯수 확인: \(Movie.movieId)")
    } else {
        print("영화데이터가 없습니다. 또는 다운로드에 실패했습니다.")
    }
}

