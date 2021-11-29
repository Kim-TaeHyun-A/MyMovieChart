//
//  ListViewController.swift
//  MyMovieChart
//
//  Created by 김태현 on 2021/11/19.
//

import UIKit

class ListViewController: UITableViewController {
    var page = 1
    lazy var list: [MovieVO] = [MovieVO]()
    @IBOutlet var moreBtn: UIButton!
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 섹션 수 여러 개라면 섹션 구분하고 맞는 값 반환
        
        // if 고정된 값 반환 -> 하드 코딩
        // 행 수와 데이터 소소의 크기 일치
        return self.list.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // 테이블 뷰 셀 객체 만들기
        let row = self.list[indexPath.row] // 행에 맞는 데이터 소스 읽기
        //UITableCell반환 -> 필요한 프로퍼티는 커스텀 클래스에 정의 -> 다운 캐스팅
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MovieCell
        
        cell.title?.text = row.title
        cell.desc?.text = row.description
        cell.opendate?.text = row.opendate
        cell.rating?.text = "\(row.rating!)"
        
        DispatchQueue.main.async {
            NSLog("비동기 실행 시작")
            cell.thumbnail.image = self.getThumbnailIamge(indexPath.row)
        }
        
        NSLog("비동기 실행 확인")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 테이블 셀 선택 시 액션 처리
        NSLog("선택된 행: \(indexPath.row)행")
    }
    
    override func viewDidLoad() {
        self.callMovieAPI()
    }
    
    
    @IBAction func more(_ sender: Any) {
        self.page += 1
        self.callMovieAPI()
        self.tableView.reloadData()
    }
    
    func callMovieAPI() {
        let url = "http://swiftapi.rubypaper.co.kr:2029/hoppin/movies?version=1&page=\(self.page)&count=10&genreId=&order=releasedateasc"
        let apiURI: URL! = URL(string: url)
        let apidata = try! Data(contentsOf: apiURI)
        let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? ""
        NSLog("API Result=\( log )")
        
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray
            
            for row in movie {
                let r = row as! NSDictionary
                let mvo = MovieVO()
                
                // Any 타입으로 읽힌 데이터 타입 캐스팅
                mvo.title = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail = r["thumbnailImage"] as? String
                mvo.detail = r["linkUrl"] as? String
                mvo.rating = (r["ratingAverage"] as! NSString).doubleValue
                
                // 웹에서 이미지 읽고 UIImage 객체에 저장
                let url = URL(string: mvo.thumbnail!)
                let imageData = try! Data(contentsOf: url!)
                mvo.thumbnailImage = UIImage(data: imageData)
                
                self.list.append(mvo)
            }
            
            let totalCount = (hoppin["totalCount"] as? NSString)!.integerValue
            
            if self.list.count >= totalCount {
                self.moreBtn.isHidden = true
            }
        } catch {
            NSLog("Parse Error")
        }
        
    }
    
    func getThumbnailIamge(_ index: Int) -> UIImage {
        let mvo = self.list[index]
        
        if let savedImage = mvo.thumbnailImage {
            return savedImage
        } else {
            let url = URL(string: mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url!)
            mvo.thumbnailImage = UIImage(data: imageData)
            
            return mvo.thumbnailImage!
        }
    }
    
}

// MARK: - 화면 전환 시 값 넘겨주기 위한 세그웨이 처리
extension ListViewController {
    // 세그웨이 실행 직선에 실행됨
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_detail" {
            let path = self.tableView.indexPath(for: sender as! MovieCell)
            let detailVC = segue.destination as? DetailViewController
            
            // 목적지 프로퍼티에 클릭한 셀 정보 할당
            // 몇 번째 행인지는 알 수 없음 <- indexPath(for: )
            detailVC?.mvo = self.list[path!.row]
        }
    }
}
