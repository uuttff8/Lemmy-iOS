//
//  SelectItemTableViewController.swift
//  Lemmy-iOS
//
//  Created by uuttff8 on 20.11.2020.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

import UIKit

final class SelectItemTableViewController: UITableViewController {
    private static let cellReuseIdentifier = "selectItemTableViewCell"

    private var viewModel: SelectItemViewModel
    private var onItemSelected: ((SelectItemViewModel.Section.Cell) -> Void)?

    init(
        style: UITableView.Style,
        viewModel: SelectItemViewModel,
        onItemSelected: ((SelectItemViewModel.Section.Cell) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onItemSelected = onItemSelected
        super.init(style: style)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseIdentifier)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int { self.viewModel.sections.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier, for: indexPath)

        if let cellViewModel = self.cellViewModel(at: indexPath) {
            cell.textLabel?.text = cellViewModel.title
            cell.accessoryType = cellViewModel.uniqueIdentifier == self.viewModel.selectedCell?.uniqueIdentifier
                ? .checkmark
                : .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.viewModel.sections[safe: section]?.headerTitle
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.viewModel.sections[safe: section]?.footerTitle
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let selectedCellViewModel = self.cellViewModel(at: indexPath) else {
            return
        }

        if let previouslySelectedCellViewModel = self.viewModel.selectedCell,
           let previouslySelectedCell = self.cell(for: previouslySelectedCellViewModel) {
            previouslySelectedCell.accessoryType = .none
        }

        if let selectedCell = tableView.cellForRow(at: indexPath) {
            selectedCell.accessoryType = .checkmark
        }

        self.viewModel.selectedCell = selectedCellViewModel

        self.onItemSelected?(selectedCellViewModel)
    }

    // MARK: Private API

    private func cell(for viewModel: SelectItemViewModel.Section.Cell) -> UITableViewCell? {
        let indexPath: IndexPath? = {
            for (sectionIndex, sectionViewModel) in self.viewModel.sections.enumerated() {
                for (cellIndex, cellViewModel) in sectionViewModel.cells.enumerated()
                    where cellViewModel.uniqueIdentifier == viewModel.uniqueIdentifier {
                    return IndexPath(row: cellIndex, section: sectionIndex)
                }
            }
            return nil
        }()

        if let indexPath = indexPath {
            return self.tableView.cellForRow(at: indexPath)
        }

        return nil
    }

    private func cellViewModel(at indexPath: IndexPath) -> SelectItemViewModel.Section.Cell? {
        self.viewModel.sections[safe: indexPath.section]?.cells[safe: indexPath.row]
    }
}

extension SelectItemTableViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        .pageSheetAppearance()
    }
}
