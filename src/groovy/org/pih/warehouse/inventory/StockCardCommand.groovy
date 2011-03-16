package org.pih.warehouse.inventory;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.pih.warehouse.inventory.Warehouse;
import org.pih.warehouse.inventory.Inventory;
import org.pih.warehouse.inventory.InventoryItem;
import org.pih.warehouse.inventory.InventoryLevel;
import org.pih.warehouse.product.Product;
import org.pih.warehouse.shipping.Shipment;

class StockCardCommand {
	
	// Used when adding a new inventory item (not implemented yet)
	InventoryItem inventoryItem;

	// Entire page
	Product productInstance;
	Warehouse warehouseInstance;
	Inventory inventoryInstance;
	InventoryLevel inventoryLevelInstance;
	
	// Current stock section
	List<InventoryItem> inventoryItemList;
	List<TransactionEntry> transactionEntryList;
	List<Shipment> pendingShipmentList;
	Map<Transaction, List<TransactionEntry>> transactionEntriesByTransactionMap;
	Map<InventoryItem, List<TransactionEntry>> transactionEntriesByInventoryItemMap

	// Transaction log section
	Date startDate = new Date() - 7;		// defaults to today - 7d
	Date endDate = new Date();				// defaults to today
	TransactionType transactionType
	Map transactionLogMap;
		
	static constraints = {
		startDate(nullable:true)
		endDate(nullable:true)
		transactionType(nullable:true)
	}

	/**
	 * Returns a map of quantity values indexed by inventory item to be used in the
	 * current stock portion of the stock card page.
	 *
	 * @return a map (inventory item -> quantity)
	 */
	Map<InventoryItem, Integer> getQuantityByInventoryItemMap() {
		Map<InventoryItem, Integer> quantityByInventoryItemMap = [:]
		if (inventoryItemList) {
			inventoryItemList.each {
				def transactionEntries = transactionEntriesByInventoryItemMap?.get(it)
				def quantity = (transactionEntries)?transactionEntries*.quantity.sum():0;
				quantityByInventoryItemMap.put(it, quantity)
			}
		}
		return quantityByInventoryItemMap;
	}
	
	/**
	 * Return the total quantity for all inventory items.
	 *
	 * @return 	the sum of quantities across all transaction entries
	 */
	Integer getTotalQuantity() {
		return (transactionEntryList)?transactionEntryList.findAll { it.product == productInstance }.quantity.sum():0
	}
	
	/**
	 * Filter the transaction entry list by date range and transaction type
	 *
	 * TODO Should move this to the DAO/service layer in order to make it perform better.
	 *
	 * @return
	 */
	Map getTransactionLogMap() {
		def filteredTransactionLog = transactionEntryList;
		if (startDate) {
			filteredTransactionLog = filteredTransactionLog.findAll{it.transaction.transactionDate >= startDate}
		}
		
		// Need to add +1 to endDate because date comparison includes time
		// TODO Should set endDate to midnight of the date to be more accurate
		if (endDate) {
			filteredTransactionLog = filteredTransactionLog.findAll{it.transaction.transactionDate <= endDate+1}
		}
		
		// Filter by transaction type (0 = return all types)
		if (transactionType && transactionType?.id != 0) {
			filteredTransactionLog = filteredTransactionLog.findAll{it?.transaction?.transactionType?.id == transactionType?.id}
		}
		
		return filteredTransactionLog.groupBy { it.transaction }
	}
	

	
	
}