<div id="requisitionItems">
    <div class="box">
        <h2>
            <warehouse:message code="requisition.verify.label" default="Verify requisition"/>
        </h2>
        <g:form controller="requisition" action="saveDetails">
            <g:hiddenField name="redirectAction" value="review"/>
            <g:hiddenField name="id" value="${requisition?.id}"/>
            <table style="width:auto;">
                <tr>
                    <td class="center middle">
                        <label>
                            ${warehouse.message(code:'requisition.dateVerified.label', default: 'Date verified')}
                        </label>

                        <g:if test="${params.edit}">
                            <g:datePicker name="dateVerified" value="${requisition?.dateVerified}" precision="day"/>
                        </g:if>
                        <g:else>
                            <g:if test="${requisition?.dateVerified}">
                                <g:formatDate date="${requisition?.dateVerified}" format="dd MMMMM yyyy"/>
                            </g:if>
                            <g:else>
                                ${warehouse.message(code:'default.none.label')}
                            </g:else>
                        </g:else>
                    </td>
                    <td class="center middle">
                        <label>
                            ${warehouse.message(code:'requisition.verifiedBy.label', default: 'Verified by')}
                        </label>
                        <g:if test="${params.edit}">
                            <g:selectPerson id="verifiedBy" name="verifiedBy.id" value="${requisition?.verifiedBy}"
                                            noSelection="['null':'']" size="40"/>
                        </g:if>
                        <g:else>
                            <g:if test="${requisition.verifiedBy}">
                                ${requisition?.verifiedBy?.name}
                            </g:if>
                            <g:else>
                                ${warehouse.message(code:'default.none.label')}
                            </g:else>
                        </g:else>
                    </td>
                    <td class="center middle">

                        <g:if test="${params.edit}">
                            <button class="button icon approve">
                                ${warehouse.message(code:'default.button.save.label')}
                            </button>
                            &nbsp;
                            <g:link controller="requisition" action="review" id="${requisition?.id}">
                                ${warehouse.message(code:'default.button.cancel.label')}
                            </g:link>
                        </g:if>
                        <g:else>
                            <g:link controller="requisition" action="review" id="${requisition?.id}"
                                    params="[edit:'on']" class="button icon edit">
                                ${warehouse.message(code:'default.button.edit.label', default: 'Edit')}
                            </g:link>
                        </g:else>
                    </td>
                </tr>


            </table>
        </g:form>
        <hr/>


        <table id="requisitionItemsTable">
            <thead>
                <tr>
                    <th class='center'>
                        <warehouse:message code="default.actions.label"/>
                    </th>

                    <th>

                    </th>
                    <th>

                    </th>
                    <th>
                        <warehouse:message code="requisitionItem.status.label" default="Status" />
                    </th>
                    <%--
                    <th>
                        <warehouse:message code="requisitionItem.type.label" default="Type" />
                    </th>
                    --%>
                    <th>
                        <warehouse:message code="requisitionItem.product.label" />
                    </th>
                    <th class="center middle">
                        <warehouse:message code="requisitionItem.quantityRequested.label" default="Requested"/>
                    </th>
                    <th class="center middle">
                        <warehouse:message code="requisitionItem.quantityApproved.label" default="Approved" />
                    </th>
                    <th class="center middle">
                        <warehouse:message code="requisitionItem.quantityAvailable.label" default="Available" />
                    </th>
                    <th>
                        <warehouse:message code="requisitionItem.cancelReasonCode.label" default="Reason code"/>
                    </th>

                </tr>
            </thead>
            <tbody>
                <g:if test="${!requisitionItems}">
                    <tr class="prop">
                        <td colspan="9" class="center empty"><warehouse:message
                                code="requisition.noRequisitionItems.message" /></td>

                    </tr>
                </g:if>
                <g:set var="count" value="${0 }"/>
                <g:set var="previousRequisitionItem" value="${null}"/>
                <g:each var="requisitionItem" in="${requisitionItems.sort()}" status="i">
                    <g:set var="isChildOfPrevious" value="${i!=0 && previousRequisitionItem == requisitionItem?.parentRequisitionItem}"/>
                    <g:if test="${!isChildOfPrevious}">
                        <g:set var="count" value="${count+1}"/>
                    </g:if>
                    <g:set var="selected" value="${requisitionItem == selectedRequisitionItem}"/>
                    <g:set var="quantityOnHand" value="${quantityOnHandMap[requisitionItem?.product?.id]} "/>
                    <g:set var="substitution" value="${requisitionItem?.substitution}"/>
                    <g:set var="quantityOnHandForSubstitution" value="${quantityOnHandMap[substitution?.product?.id]} "/>
                    <%--<g:set var="quantityRemaining" value="${(requisitionItem?.quantity?:0)-(requisitionItem?.calculateQuantityPicked()?:0)}" />--%>
                    <%-- Need to hack this in since the quantityOnHand value was a String --%>
                    <g:set var="isCanceled" value="${requisitionItem?.isCanceled()}"/>
                    <g:set var="isChanged" value="${requisitionItem?.isChanged()}"/>
                    <g:set var="hasSubstitution" value="${requisitionItem?.hasSubstitution()}"/>
                    <g:set var="quantityOnHand" value="${quantityOnHand.toInteger()}"/>
                    <g:set var="isAvailable" value="${(quantityOnHand > 0) && (quantityOnHand >= requisitionItem?.totalQuantity()) }"/>
                    <g:set var="isAvailableForSubstitution" value="${hasSubstitution && (quantityOnHandForSubstitution > 0) && (quantityOnHandForSubstitution >= requisitionItem?.substitution?.totalQuantity()) }"/>
                    <g:set var="rowClass" value="${count%2?'odd':'even'}"/>

                    <tr class="${requisitionItem.isChanged()?'modified':''} ${requisitionItem?.isSubstituted()?'substituted':''} ${requisitionItem.isCanceled()?'canceled':''} ${rowClass}">
                        <td class="middle">
                            <%--
                            <g:remoteLink controller="requisitionItem" action="approveQuantity" id="${requisitionItem?.id }" class="button icon approve">
                                <warehouse:message code="requisitionItem.approve.label" default="Approve"/>
                            </g:remoteLink>
                            <g:link controller="requisition" action="editRequisitionItem" id="${requisitionItem?.id}" class="button icon edit">
                                <warehouse:message code="requisitionItem.edit.label" default="Edit"/>
                            </g:link>

                            <g:remoteLink controller="requisition" action="approveQuantity" id="${requisitionItem?.id }" params="['requisition.id':requisitionItem.requisition.id]">
                                <warehouse:message code="default.button.approve.label" default="Approve"/>
                            </g:remoteLink>
                            <g:remoteLink controller="requisition" action="editRequisitionItem" update="requisitionItems" id="${requisitionItem.id}">
                                <warehouse:message code="default.button.edit.label" default="Edit"/>
                            </g:remoteLink>

                            <g:remoteLink controller="requisition" action="undoChanges" id="${requisitionItem?.id }" params="['requisition.id':requisitionItem.requisition.id]"
                                    onclick="return confirm('${warehouse.message(code: 'default.button.undo.confirm.message', default: 'Are you sure?')}');">
                                <warehouse:message code="default.button.undo.label" default="Undo"/>
                            </g:remoteLink>
                            --%>

                            <div>

                                <g:if test="${!requisitionItem.parentRequisitionItem}">
                                <%--
                                <g:if test="${requisitionItem?.canApproveQuantity()}">
                                    <div class="action-menu-item">
                                        <g:remoteLink controller="requisition" action="approveQuantity" id="${requisition?.id }" class="button"
                                                params="['requisitionItem.id':requisitionItem?.id, actionType:'approveQuantity']" update="requisitionItems">
                                            <img src="${resource(dir: 'images/icons/silk', file: 'accept.png')}"/>                                                </g:remoteLink>
                                    </div>
                                </g:if>
                                --%>
                                    <g:if test="${requisitionItem.canChangeQuantity()||requisitionItem.canChooseSubstitute()||requisitionItem?.canApproveQuantity()}">
                                        <div class="action-menu-item">
                                            <g:remoteLink controller="requisition" action="editRequisitionItem" id="${requisition?.id }" class="button"
                                                          onFailure="alert('An error has occurred.  Please contact your system administrator (${requisition.requestNumber}).')"
                                                          params="['requisitionItem.id':requisitionItem?.id, actionType:'show']" update="requisitionItems">
                                                <img src="${resource(dir: 'images/icons/silk', file: 'pencil.png')}"/>
                                            </g:remoteLink>
                                        </div>
                                    </g:if>
                                <%--
                                <g:if test="${requisitionItem.canChooseSubstitute()}">
                                    <div class="action-menu-item">
                                        <g:remoteLink controller="requisition" action="editRequisitionItem" id="${requisition?.id }" update="requisitionItems"
                                                params="['requisitionItem.id':requisitionItem?.id, actionType:'chooseSubstitute']" >
                                            <img src="${resource(dir: 'images/icons/silk', file: 'arrow_switch.png')}"/>&nbsp;
                                            <warehouse:message code="requisitionItem.substitute.label" default="Choose substitute"/>
                                        </g:remoteLink>
                                    </div>
                                </g:if>
                                <g:if test="${requisitionItem.canChangeQuantity()}">
                                    <div class="action-menu-item">
                                        <g:remoteLink controller="requisition" action="editRequisitionItem" id="${requisition?.id }"
                                                params="['requisitionItem.id':requisitionItem?.id, actionType:'cancelQuantity']" update="requisitionItems">
                                            <img src="${resource(dir: 'images/icons/silk', file: 'decline.png')}"/>&nbsp;
                                            <warehouse:message code="requisitionItem.cancel.label" default="Cancel requisition item"/>
                                        </g:remoteLink>
                                    </div>
                                </g:if>
                                --%>
                                    <g:if test="${requisitionItem.canUndoChanges()}">
                                        <div class="action-menu-item">
                                            <g:remoteLink controller="requisition" action="undoChangesFromList" id="${requisition?.id }" class="button"
                                                          params="['requisitionItem.id':requisitionItem?.id,actionType:'undoChanges']" update="requisitionItems"
                                                          onFailure="alert('An error has occurred.  Please contact your system administrator (re: ${requisition.requestNumber}).')"
                                                          onclick="return confirm('${warehouse.message(code: 'default.button.undo.confirm.message', default: 'Are you sure?')}');">
                                                <img src="${resource(dir: 'images/icons/silk', file: 'cross.png')}"/>
                                            </g:remoteLink>
                                        </div>
                                    </g:if>
                                </g:if>
                                <g:else>

                                    <div class="action-menu-item">
                                        <g:remoteLink controller="requisition" action="undoChangesFromList" id="${requisition?.id }" class="button"
                                                      params="['requisitionItem.id':requisitionItem?.parentRequisitionItem?.id,actionType:'undoChanges']" update="requisitionItems"
                                                      onFailure="alert('An error has occurred.  Please contact your system administrator (re: ${requisition.requestNumber}).')"
                                                      onclick="return confirm('${warehouse.message(code: 'default.button.undo.confirm.message', default: 'Are you sure?')}');">
                                            <img src="${resource(dir: 'images/icons/silk', file: 'cross.png')}"/>
                                        </g:remoteLink>
                                    </div>
                                </g:else>
                            </div>
                        </td>
                        <td class="middle center">
                            ${i+1}
                        </td>
                        <td class="middle center">
                            <g:if test="${requisitionItem?.isSubstituted()}">
                                <img src="${resource(dir:'images/icons/silk',file:'arrow_switch.png')}"/>
                            </g:if>
                            <g:elseif test="${requisitionItem?.isSubstitution()}">
                                <img src="${resource(dir:'images/icons',file:'indent.gif')}"/>
                            </g:elseif>
                            <g:elseif test="${requisitionItem?.isChanged()}">
                                <img src="${resource(dir:'images/icons/silk',file:'pencil.png')}"/>
                            </g:elseif>
                            <g:elseif test="${requisitionItem?.isPending()}">
                                <img src="${resource(dir:'images/icons/silk',file:'hourglass.png')}"/>
                            </g:elseif>
                            <g:elseif test="${requisitionItem?.isCanceled()}">
                                <img src="${resource(dir:'images/icons/silk',file:'decline.png')}"/>
                            </g:elseif>
                            <g:elseif test="${requisitionItem?.isApproved()||requisitionItem?.isCompleted()}">
                                <img src="${resource(dir:'images/icons/silk',file:'accept.png')}"/>
                            </g:elseif>
                        </td>
                        <td class="middle left">
                            <format:metadata obj="${requisitionItem?.status}"/>
                        </td>
                        <td class="middle">
                            <g:if test="${requisitionItem?.isCanceled()}">
                                <div class="canceled">
                                    ${requisitionItem?.product?.productCode}
                                    ${requisitionItem?.product?.name} (${requisitionItem?.product?.unitOfMeasure})
                                </div>
                            </g:if>
                            <g:elseif test="${requisitionItem?.isSubstituted()}">
                                <div class="canceled">
                                    ${requisitionItem?.product?.productCode}
                                    ${requisitionItem?.product?.name} (${requisitionItem?.product?.unitOfMeasure})
                                </div>
                                <div>
                                    ${requisitionItem?.substitutionItem?.product?.productCode}
                                    ${requisitionItem?.substitutionItem?.product?.name} (${requisitionItem?.substitutionItem?.product?.unitOfMeasure})
                                </div>
                            </g:elseif>
                            <g:else>
                                ${requisitionItem?.product?.productCode}
                                ${requisitionItem?.product} (${requisitionItem?.product?.unitOfMeasure})
                            </g:else>
                        </td>
                        <td class="center middle">
                            <g:if test="${requisitionItem?.isSubstituted()}">
                                <div class="canceled">
                                    ${requisitionItem?.quantity?:0}
                                </div>
                                <div>
                                    ${requisitionItem?.substitutionItem?.quantity?:0}
                                </div>
                            </g:if>
                            <g:elseif test="${requisitionItem?.isChanged()}">
                                <div class="canceled">
                                    ${requisitionItem?.quantity?:0}
                                </div>
                                <div>
                                    ${requisitionItem?.modificationItem?.quantity?:0}
                                </div>
                            </g:elseif>
                            <g:elseif test="${requisitionItem?.isCanceled()}">
                                <div class="canceled">
                                    ${requisitionItem?.quantity?:0}
                                </div>
                            </g:elseif>
                            <g:else>
                                ${requisitionItem?.quantity?:0}
                            </g:else>
                        </td>

                        <td class="center middle">
                            <g:if test="${requisitionItem?.isSubstituted()}">
                                <div class="canceled">
                                    ${requisitionItem?.quantityApproved?:0}
                                </div>
                                <div>
                                    ${requisitionItem?.substitutionItem?.quantityApproved?:0}
                                </div>
                            </g:if>
                            <g:elseif test="${requisitionItem?.isChanged()}">
                                <div class="canceled">
                                    ${requisitionItem?.quantityApproved?:0}
                                </div>
                                <div>
                                    ${requisitionItem?.modificationItem?.quantityApproved?:0}
                                </div>
                            </g:elseif>
                            <g:elseif test="${requisitionItem?.isCanceled()}">
                                <div class="canceled">
                                    ${requisitionItem?.quantityApproved?:0}
                                </div>
                            </g:elseif>
                            <g:else>
                                <div class="approved">
                                    ${requisitionItem?.quantityApproved?:0}
                                </div>
                            </g:else>
                        </td>
                        <td class="center middle">
                            <div class="box-status ${isAvailable||isAvailableForSubstitution?'success':'error'}">
                                <g:if test="${requisitionItem?.isSubstituted()}">
                                    ${quantityOnHandMap[requisitionItem?.substitutionItem?.product?.id]?:0}
                                </g:if>
                                <g:elseif test="${requisitionItem?.isChanged()}">
                                    ${quantityOnHandMap[requisitionItem?.modificationItem?.product?.id]?:0}
                                </g:elseif>
                                <g:elseif test="${requisitionItem?.isCanceled()}">
                                    ${quantityOnHandMap[requisitionItem?.product?.id]?:0}
                                </g:elseif>
                                <g:else>
                                    ${quantityOnHandMap[requisitionItem?.product?.id]?:0}
                                </g:else>
                            </div>
                        </td>
                        <td>
                            <g:if test="${requisitionItem?.cancelReasonCode}">
                                <warehouse:message code="enum.ReasonCode.${requisitionItem?.cancelReasonCode}"/>
                                <p>${requisitionItem?.cancelComments}</p>
                            </g:if>
                        </td>

                    </tr>
                    <g:set var="previousRequisitionItem" value="${requisitionItem}"/>
                </g:each>
            </tbody>
            <tfoot>
                <tr>

                </tr>
            </tfoot>
        </table>

    </div>

    <div class="button-container center">
        <g:link controller="requisition" action="edit" id="${requisition.id }" class="button icon arrowleft">
            <warehouse:message code="default.button.back.label"/>
        </g:link>

        <g:link controller="requisition" action="pick" id="${requisition.id }" class="button icon arrowright">
            <warehouse:message code="default.button.next.label"/>
        </g:link>
    </div>

</div>
<script>

</script>