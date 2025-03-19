//
//  ImageLoader.swift
//  LubasApp
//
//  Created by lpd on 2025/3/5.
//


import UIKit
import Combine
import Kingfisher

class ImageLoader {
    private var cancellables = Set<AnyCancellable>()
    private let imageSubject = PassthroughSubject<(UIImage?, Int), Never>()  // 传递图片和索引

    var imagePublisher: AnyPublisher<(UIImage?, Int), Never> {
        imageSubject.eraseToAnyPublisher()
    }

    func loadImagesSequentially(urls: [String]) {
        urls.enumerated().publisher // 使用 `enumerated()` 生成 (index, url) 元组
                .flatMap { index, url in
                    self.loadImage(from: url)
                        .delay(for: .seconds(0.5 * Double(index)), scheduler: DispatchQueue.main)
                        .map { ($0, index) } // 绑定索引
                }
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] result in
                    self?.imageSubject.send(result) // 传递 (图片, 索引)
                })
                .store(in: &cancellables)
    }

    private func loadImage(from url: String) -> AnyPublisher<UIImage?, Never> {
        return Future<UIImage?, Never> { promise in
            guard let imageURL = URL(string: url) else {
                promise(.success(nil))
                return
            }
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                switch result {
                case .success(let value):
                    promise(.success(value.image))
                case .failure:
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
