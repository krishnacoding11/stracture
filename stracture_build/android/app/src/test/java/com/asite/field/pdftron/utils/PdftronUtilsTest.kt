package com.asite.field.pdftron.utils


import com.pdftron.pdf.Annot
import com.pdftron.pdf.PDFViewCtrl
import org.junit.Assert.*
import org.junit.Test
import org.mockito.Mockito

/**
 * Created by Chandresh Patel on 24-07-2023.
 */
class PdftronUtilsTest {

    @Test
    fun isLocationAnnot() {
        val locationAnnot = Mockito.mock(Annot::class.java)
        Mockito.`when`(locationAnnot.isValid).thenReturn(true)
        Mockito.`when`(locationAnnot.type).thenReturn(Annot.e_Square)
        val otherAnnot = Mockito.mock(Annot::class.java)
        Mockito.`when`(otherAnnot.isValid).thenReturn(true)
        Mockito.`when`(otherAnnot.type).thenReturn(Annot.e_Stamp)
        assertTrue(PdftronUtils.isLocationAnnot(locationAnnot))
        assertFalse(PdftronUtils.isLocationAnnot(otherAnnot))
    }

    @Test
    fun requestResetRenderingPdftron() {
        val mockPDFViewCtrl = Mockito.mock(PDFViewCtrl::class.java)
        Mockito.`when`(mockPDFViewCtrl.pageViewMode).thenReturn(PDFViewCtrl.PageViewMode.FIT_PAGE)
        Mockito.`when`(mockPDFViewCtrl.preferredViewMode)
            .thenReturn(PDFViewCtrl.PageViewMode.FIT_PAGE)

        PdftronUtils.requestResetRenderingPdftron(mockPDFViewCtrl)

        assertEquals(mockPDFViewCtrl.preferredViewMode, PDFViewCtrl.PageViewMode.FIT_PAGE)
        assertEquals(mockPDFViewCtrl.pageViewMode, PDFViewCtrl.PageViewMode.FIT_PAGE)
        assertFalse(mockPDFViewCtrl.directionalLockEnabled)
    }

}