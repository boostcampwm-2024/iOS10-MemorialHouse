import MHDomain

public struct CategoryViewModelFactory {
    let createCategoryUseCase: CreateCategoryUseCase
    let updateCategoryUseCase: UpdateCategoryUseCase
    let deleteCategoryUseCase: DeleteCategoryUseCase
    
    public init(
        createCategoryUseCase: CreateCategoryUseCase,
        updateCategoryUseCase: UpdateCategoryUseCase,
        deleteCategoryUseCase: DeleteCategoryUseCase
    ) {
        self.createCategoryUseCase = createCategoryUseCase
        self.updateCategoryUseCase = updateCategoryUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
    }
    
    func make() -> CategoryViewModel {
        CategoryViewModel(
            createCategoryUseCase: createCategoryUseCase,
            updateCategoryUseCase: updateCategoryUseCase,
            deleteCategoryUseCase: deleteCategoryUseCase
        )
    }
}
