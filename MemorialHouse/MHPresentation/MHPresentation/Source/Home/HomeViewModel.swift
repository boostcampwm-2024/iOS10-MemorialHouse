import MHDomain

public final class HomeViewModel {
    let dummyBook = [
        BookCover(title: "집주인들", imageURL: "", bookColor: .pink, category: "친구", isLike: false),
        BookCover(title: "엄마", imageURL: "", bookColor: .blue, category: "가족", isLike: true),
        BookCover(title: "아빠", imageURL: "", bookColor: .green, category: "가족", isLike: true),
        BookCover(title: "친구", imageURL: "", bookColor: .beige, category: "가족", isLike: false),
        BookCover(title: "동생", imageURL: "", bookColor: .orange, category: "가족", isLike: true),
        BookCover(title: "집주인들", imageURL: "", bookColor: .pink, category: "친구", isLike: false),
        BookCover(title: "엄마", imageURL: "", bookColor: .blue, category: "가족", isLike: true),
        BookCover(title: "아빠", imageURL: "", bookColor: .green, category: "가족", isLike: true),
        BookCover(title: "친구", imageURL: "", bookColor: .beige, category: "가족", isLike: false),
        BookCover(title: "동생", imageURL: "", bookColor: .orange, category: "가족", isLike: true),
        BookCover(title: "집주인들", imageURL: "", bookColor: .pink, category: "친구", isLike: false),
        BookCover(title: "엄마", imageURL: "", bookColor: .blue, category: "가족", isLike: true),
        BookCover(title: "아빠", imageURL: "", bookColor: .green, category: "가족", isLike: true),
        BookCover(title: "친구", imageURL: "", bookColor: .beige, category: "가족", isLike: false),
        BookCover(title: "동생", imageURL: "", bookColor: .orange, category: "가족", isLike: true),
        BookCover(title: "집주인들", imageURL: "", bookColor: .pink, category: "친구", isLike: false),
        BookCover(title: "엄마", imageURL: "", bookColor: .blue, category: "가족", isLike: true),
        BookCover(title: "아빠", imageURL: "", bookColor: .green, category: "가족", isLike: true),
        BookCover(title: "친구", imageURL: "", bookColor: .beige, category: "가족", isLike: false),
        BookCover(title: "동생", imageURL: "", bookColor: .orange, category: "가족", isLike: true)
    ]
    let houseName: String
    
    public init(houseName: String) { // TODO: 기록소 모델 만들기
        self.houseName = houseName
    }
}
