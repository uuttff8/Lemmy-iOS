//
//  CommunityHeaderCell.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 04.11.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

class CommunityHeaderCell: UITableViewCell {
    
    let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }
        
    let communityHeaderView = CommunityHeaderView()
    let contentTypeView = CommunityContentTypePickerView()
    
    var presentParsedVc: ((String) -> Void)?
        
    init() {
        super.init(style: .default, reuseIdentifier: String(describing: Self.self))
        
        selectionStyle = .none
        self.backgroundColor = .systemBackground
        
        contentView.addSubview(mainStackView)
        
        mainStackView.addStackViewItems(
            .view(communityHeaderView),
            .view(UIView.Configutations.separatorView),
            .view(contentTypeView)
        )
        
        mainStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentView)
        }
    }
    
    func bindData(community: LemmyApiStructs.CommunityView) {
        communityHeaderView.bind(with: community)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
